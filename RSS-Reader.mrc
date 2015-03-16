; -----------------------------------------------------------------------------------
;HTTP Transfer Script
;beta phase!
;
;Original script: Tomalak Geret'kal from www.deep-space-5.org/mirchelp.php";
;Usage: /httpget http://<host>/<path> [local_folder]
;
;-------------------------------------------------------------------------------------*/
alias httpget {
  if ($regex($1,/^http:\/\/([^\/]+)(\/.+)$/i)) {
    window -e @RSS_LTB
    echo @RSS_LTB $asctime(HH:nn:ss) [HTTP] Opening to  $+ $regml(1) $+  on port: 80

    set %RSS.chans #thienthan
    set %RSS.name @RSS_LTB
    set %RSSsite $gettok($remove($1,http://),1,47)
    set %RSSurl $remove($1,http://,%RSSsite)
    if (!$hget(%RSSsite)) { hmake %RSSsite 10 }
    set %RSS.Count 1
    set %RSS.Max 4

    var %name = httpget_socket

    sockclose %name
    sockopen %name $regml(1) 80
    set % $+ %name $+ .url $regml(1)
    set % $+ %name $+ .path $regml(2)

    var %2 = $2
    set % $+ %name $+ .saveto %2
    write -c rss.txt
    write rss.txt %RSSsite %RSSurl
  }
}
on *:sockopen:httpget_socket: {
  sockwrite -nt $sockname GET %RSSurl HTTP/1.0
  ;sockwrite -n $sockname User-Agent: Opera 9.6
  sockwrite -n $sockname User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.8) Gecko/2009032711 Ubuntu/8.10 (intrepid) Firefox/3.0.8
  sockwrite -n $sockname Host: %RSSsite $+ $CRLF $+ $CRLF
}
on *:sockwrite:httpget_socket:{
  if ($sockerr) echo @RSS_LTB $asctime(HH:nn:ss) • Error: $ifmatch
}

on *:sockread:httpget_socket:{
  if ($sockerr > 0) { echo @RSS_LTB $asctime(HH:nn:ss) There has been an error... >RSS1.0<>Sock Error< |  RSS.clear }
  else {
    var %RSSvar | sockread %RSSvar
    write rss.txt %RSSvar
    if (<entry> isin %RSSvar) { set %RSS.Start on }
    if (</entry> isin %RSSvar) || (</item> isin %RSSvar) {
      set %RSS.Dup Off
      if ($hfind(%RSSsite,$right($remove(%RSS.title,$chr(32)),70))) { set %RSS.Dup ON }
      if (%RSS.Dup == Off) && (%RSS.Count <= %RSS.Max) {
        set %RSS.Output 1
        while $gettok(%RSS.Chans,%RSS.Output,44) {
          if ($gettok(%RSS.Chans,%RSS.Output,44) ischan) {
            ;.msg $gettok(%RSS.Chans,%RSS.Output,44) 04 $+ %RSS.Name 07 $+ $remove(%RSS.Title,&amp;,&quot;,&gt;) 06 $+ $replace($nospace(%RSS.Link),$chr(32),$chr(37) $+ 20)
            .echo @RSS_LTB $asctime(HH:nn:ss) 04 $+ %RSS.Name 07 $+ $remove(%RSS.Title,&amp;,&quot;,&gt;) 06 $+ $replace($nospace(%RSS.Link),$chr(32),$chr(37) $+ 20)
          }
          inc %RSS.Output
        }
        inc %RSS.Count
        ;echo -a $replace(%RSS.Link,$chr(32),$chr(37) $+ 20)
      }
      ;;;hadd %RSSsite $right($remove(%RSS.title,$chr(32)),70) %RSS.Link $+ $chr(7) $+ %RSS.Title $+ $chr(7) $+ %RSS.Date $+ $chr(7)
      ;write HETHONG\rss.txt $remove(%RSS.Title,<![CDATA[,]]>) %RSS.Link
      if ($read(HETHONG\rss.txt,w,$+(*,%RSS.Link,*)) == $null) { write HETHONG\rss.txt $remove(%RSS.Title,<![CDATA[,]]>) %RSS.Link }

    }
    if (<title> isin %RSSvar) {
      set %RSS.Title $gettok($replace(%RSSvar,<title>,$chr(7),</title>,$chr(7)),2,7)
    }
    if ($left(%RSSvar,7) == <title>) {
      set %RSS.Title $remove(%RSSvar,<title>,</title>)
    }
    if (<link href=" isin %RSSvar) {
      set %RSS.Link $nospace($remove(%RSSvar,<link href="," />))
    }
    if (<link> isin %RSSvar) {
      set %RSS.Link $gettok($replace(%RSSvar,<link>,$chr(7),</link>,$chr(7)),2,7)
    }
    if ($left(%RSSvar,6) == <link>) {
      set %RSS.Link $remove(%RSSvar,<link>,</link>)
    }
    if  (<updated> isin %RSSvar) {
      set %RSS.Date $gettok($replace(%RSSvar,<updated>,$chr(7),</updated>,$chr(7)),2,7)
    }
    if ($left(%RSSvar,9) == <updated>) {
      set %RSS.Date $remove(%RSSvar,<updated>,</updated>)
    }
    if (<pubdate> isin %RSSvar) {
      set %RSS.Date $gettok($replace(%RSSvar,<pubdate>,$chr(7),</pubdate>,$chr(7)),2,7)
    }
    if ($left(%RSSvar,9) == <pubdate>) {
      set %RSS.Date $remove(%RSSvar,<pubdate>,</pubdate>)
    }
    if (</feed> isin %RSSvar) || (</rss> isin %RSSvar) || (</channel> isin %RSSvar) { RSS.Clear }
  }
}

on *:sockclose:httpget_socket:{
  .unset % $+ $sockname $+ .*
}
alias -l RSS.clear {
  unset %RSS*
  sockclose RSS
  ;;;hfree -sw %RSSsite
  .timer-RSS off
  halt
}
alias -l nospace {
  var %space.check = $1-
  while ($left(%space.check,1) == $chr(32)) { %space.check = $right(%space.check,$calc($len(%space.check) - 1)) }
  while ($right(%space.check,1) == $chr(32)) { %space.check = $left(%space.check,$calc($len(%space.check) -1)) }
  return $replace(%space.check,&amp;,&)
}
alias -l httpstrip {
  var %x, %i = $regsub($1-,/(^[^<]*>|<[^>]*>|<[^>]*$)/g,$null,%x), %x = $remove(%x,&nbsp;)
  return %x
}
