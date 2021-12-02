# README-APPLE-SILICON

Notes on porting XBB to Apple Silicon, in reverse chronological order:

## 2021-12-02

Git fails with:

```console
Testing if git binaries start properly...

[/Users/ilg/.local/xbb/bin/git --version]
git version 2.33.1

[/Users/ilg/.local/xbb/bin/git clone https://github.com/xpack-dev-tools/content.git content.git]
Cloning into 'content.git'...
fatal: unable to access 'https://github.com/xpack-dev-tools/content.git/': The requested URL returned error: 405
ilg@xbbma ~ %
ilg@xbbma ~ % cd tmp
ilg@xbbma tmp % export GIT_TRACE=1
ilg@xbbma tmp % export GIT_TRACE_CURL=1
ilg@xbbma tmp % /Users/ilg/.local/xbb/bin/git clone https://github.com/xpack-dev-tools/content.git content.git
13:48:24.653317 git.c:455               trace: built-in: git clone https://github.com/xpack-dev-tools/content.git content.git
Cloning into 'content.git'...
13:48:24.661371 run-command.c:666       trace: run_command: git remote-https origin https://github.com/xpack-dev-tools/content.git
13:48:24.670577 git.c:743               trace: exec: git-remote-https origin https://github.com/xpack-dev-tools/content.git
13:48:24.670906 run-command.c:666       trace: run_command: git-remote-https origin https://github.com/xpack-dev-tools/content.git
13:48:24.684802 http.c:756              == Info: Couldn't find host github.com in the (nil) file; using defaults
13:48:24.688829 http.c:756              == Info:   Trying 140.82.114.4:443...
13:48:24.755603 http.c:756              == Info: Connected to github.com (140.82.114.4) port 443 (#0)
13:48:24.755960 http.c:756              == Info: ALPN, offering http/1.1
13:48:24.764841 http.c:756              == Info:  CAfile: /Users/ilg/.local/xbb/openssl/ca-bundle.crt
13:48:24.764848 http.c:756              == Info:  CApath: none
13:48:24.765069 http.c:729              => Send SSL data, 0000000005 bytes (0x00000005)
13:48:24.765073 http.c:744              => Send SSL data: .....
13:48:24.765082 http.c:756              == Info: TLSv1.3 (OUT), TLS handshake, Client hello (1):
13:48:24.765086 http.c:729              => Send SSL data, 0000000512 bytes (0x00000200)
13:48:24.765088 http.c:744              => Send SSL data: ......T...K7.. .....Vt.Q8L..q@...x..5. ..NC...:._E.v..3?.Q..
13:48:24.765091 http.c:744              => Send SSL data: V......._SC.>.......,.0.........+./...$.(.k.#.'.g.....9.....
13:48:24.765093 http.c:744              => Send SSL data: 3.....=.<.5./.....u.........github.com......................
13:48:24.765096 http.c:744              => Send SSL data: ..3t.........http/1.1.........1.....0.......................
13:48:24.765098 http.c:744              => Send SSL data: ..........................+............-.....3.&.$... w~....
13:48:24.765100 http.c:744              => Send SSL data: .."..'D..U@y.59.x.|hX....<..................................
13:48:24.765103 http.c:744              => Send SSL data: ............................................................
13:48:24.765105 http.c:744              => Send SSL data: ............................................................
13:48:24.765107 http.c:744              => Send SSL data: ................................
13:48:24.832601 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.832625 http.c:744              <= Recv SSL data: ....z
13:48:24.832649 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Server hello (2):
13:48:24.832654 http.c:729              <= Recv SSL data, 0000000122 bytes (0x0000007a)
13:48:24.832657 http.c:744              <= Recv SSL data: ...v...]*s9...p.|............Y.^.i;.PL ..NC...:._E.v..3?.Q..
13:48:24.832660 http.c:744              <= Recv SSL data: V......._SC......+.....3.$... .....^...e..Y.k+#.....#..Xu.Z.
13:48:24.832663 http.c:744              <= Recv SSL data: ./
13:48:24.832915 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.832920 http.c:744              <= Recv SSL data: .....
13:48:24.832926 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.832928 http.c:744              <= Recv SSL data: ....*
13:48:24.832940 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.832942 http.c:744              <= Recv SSL data: .
13:48:24.832948 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
13:48:24.832952 http.c:729              <= Recv SSL data, 0000000025 bytes (0x00000019)
13:48:24.832954 http.c:744              <= Recv SSL data: .................http/1.1
13:48:24.832963 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.832965 http.c:744              <= Recv SSL data: ....L
13:48:24.832973 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.832975 http.c:744              <= Recv SSL data: .
13:48:24.832981 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Certificate (11):
13:48:24.832985 http.c:729              <= Recv SSL data, 0000002363 bytes (0x0000093b)
13:48:24.832988 http.c:744              <= Recv SSL data: ...7...3...0...0.............w......a.<Af.0...*.H.=...0g1.0.
13:48:24.832991 http.c:744              <= Recv SSL data: ..U....US1.0...U....DigiCert, Inc.1?0=..U...6DigiCert High A
13:48:24.832994 http.c:744              <= Recv SSL data: ssurance TLS Hybrid ECC SHA256 2020 CA10...210325000000Z..22
13:48:24.832997 http.c:744              <= Recv SSL data: 0330235959Z0f1.0...U....US1.0...U....California1.0...U....Sa
13:48:24.832999 http.c:744              <= Recv SSL data: n Francisco1.0...U....GitHub, Inc.1.0...U....github.com0Y0..
13:48:24.833002 http.c:744              <= Recv SSL data: .*.H.=....*.H.=....B.....u..IT.].q..%.K"..#N.......9..#.....
13:48:24.833005 http.c:744              <= Recv SSL data: Z.E.....#z....G....vkP6f.....:0..60...U.#..0...Pa...5..* ...
13:48:24.833008 http.c:744              <= Recv SSL data: .B..).K0...U......'.~..&.P...S[.1....r0%..U....0...github.co
13:48:24.833010 http.c:744              <= Recv SSL data: m..www.github.com0...U...........0...U.%..0...+.........+...
13:48:24.833013 http.c:744              <= Recv SSL data: ....0....U.....0..0Q.O.M.Khttp://crl3.digicert.com/DigiCertH
13:48:24.833016 http.c:744              <= Recv SSL data: ighAssuranceTLSHybridECCSHA2562020CA1.crl0Q.O.M.Khttp://crl4
13:48:24.833018 http.c:744              <= Recv SSL data: .digicert.com/DigiCertHighAssuranceTLSHybridECCSHA2562020CA1
13:48:24.833021 http.c:744              <= Recv SSL data: .crl0>..U. .70503..g.....0)0'..+.........http://www.digicert
13:48:24.833024 http.c:744              <= Recv SSL data: .com/CPS0....+..........0..0$..+.....0...http://ocsp.digicer
13:48:24.833026 http.c:744              <= Recv SSL data: t.com0Z..+.....0..Nhttp://cacerts.digicert.com/DigiCertHighA
13:48:24.833029 http.c:744              <= Recv SSL data: ssuranceTLSHybridECCSHA2562020CA1.crt0...U.......0.0.....+..
13:48:24.833032 http.c:744              <= Recv SSL data: ...y............v.)y...99!.Vs.c.w..W}.`...M]&\%].....xj.....
13:48:24.833035 http.c:744              <= Recv SSL data: ...G0E.!....D.4E.2M.......c-.._c.F...9... HT'..2...w...h...
13:48:24.833037 http.c:744              <= Recv SSL data: ......4....rD.Y.w."EE.YU$V.?./..m..#&c..K]..\n......xj..9..
13:48:24.833040 http.c:744              <= Recv SSL data: ...H0F.!....J.A...\(.....lX......j.../.i.!.......h........R
13:48:24.833043 http.c:744              <= Recv SSL data: g0...;..........0...*.H.=....G.0D. +...o.*E.5.7=.....g....hk
13:48:24.833046 http.c:744              <= Recv SSL data: ..I..FV. ..]-.Y...=u.s....~...2.......D>......0...0.........
13:48:24.833048 http.c:744              <= Recv SSL data: ..g.[...c....SN..0...*.H........0l1.0...U....US1.0...U....Di
13:48:24.833051 http.c:744              <= Recv SSL data: giCert Inc1.0...U....www.digicert.com1+0)..U..."DigiCert Hig
13:48:24.833054 http.c:744              <= Recv SSL data: h Assurance EV Root CA0...201217000000Z..301216235959Z0g1.0.
13:48:24.833057 http.c:744              <= Recv SSL data: ..U....US1.0...U....DigiCert, Inc.1?0=..U...6DigiCert High A
13:48:24.833059 http.c:744              <= Recv SSL data: ssurance TLS Hybrid ECC SHA256 2020 CA10Y0...*.H.=....*.H.=.
13:48:24.833062 http.c:744              <= Recv SSL data: ...B..g.o.<......l.............~.S....>.r..H}..C.#.....k...K
13:48:24.833065 http.c:744              <= Recv SSL data: ;C....?NG.....0...0...U.......0.......0...U......Pa...5..* .
13:48:24.833067 http.c:744              <= Recv SSL data: ...B..).K0...U.#..0....>.i...G...&....cd+.0...U...........0.
13:48:24.833070 http.c:744              <= Recv SSL data: ..U.%..0...+.........+.......0..+........s0q0$..+.....0...h
13:48:24.833073 http.c:744              <= Recv SSL data: ttp://ocsp.digicert.com0I..+.....0..=http://cacerts.digicert
13:48:24.833075 http.c:744              <= Recv SSL data: .com/DigiCertHighAssuranceEVRootCA.crt0K..U...D0B0@.>.<.:htt
13:48:24.833078 http.c:744              <= Recv SSL data: p://crl3.digicert.com/DigiCertHighAssuranceEVRootCA.crl00..U
13:48:24.833081 http.c:744              <= Recv SSL data: . .)0'0...g.....0...g.....0...g....0...g.....0...*.H........
13:48:24.833084 http.c:744              <= Recv SSL data: .....s...a...o.....L......."...d.........m......y.........1.
13:48:24.833086 http.c:744              <= Recv SSL data: ....8.h#....aJgO.:.*...<..5fgj..%UE.....~-.....|L..~.....Et
13:48:24.833089 http.c:744              <= Recv SSL data: }'...FvT...9CG5.h.y1...Me..h..<..;....<^Y./..~..S..j*...^Q..
13:48:24.833092 http.c:744              <= Recv SSL data: a.......,..zv.w.....S<>J.....d......i.P`.........N*C.-...@z
13:48:24.833095 http.c:744              <= Recv SSL data: .0......TX.8....h.6.=..
13:48:24.834371 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.834383 http.c:744              <= Recv SSL data: ....`
13:48:24.834390 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.834392 http.c:744              <= Recv SSL data: .
13:48:24.834398 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, CERT verify (15):
13:48:24.834402 http.c:729              <= Recv SSL data, 0000000079 bytes (0x0000004f)
13:48:24.834405 http.c:744              <= Recv SSL data: ...K...G0E. W...)N....V...9..hY.+I..eY2...O..!.....O."[.1..N
13:48:24.834408 http.c:744              <= Recv SSL data: ....|.[......B...4<
13:48:24.834593 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.834599 http.c:744              <= Recv SSL data: ....5
13:48:24.834605 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.834608 http.c:744              <= Recv SSL data: .
13:48:24.834632 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Finished (20):
13:48:24.834636 http.c:729              <= Recv SSL data, 0000000036 bytes (0x00000024)
13:48:24.834638 http.c:744              <= Recv SSL data: ... ..PV.#.aG}...3..........`P{...J.
13:48:24.834680 http.c:729              => Send SSL data, 0000000005 bytes (0x00000005)
13:48:24.834683 http.c:744              => Send SSL data: .....
13:48:24.834688 http.c:756              == Info: TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
13:48:24.834691 http.c:729              => Send SSL data, 0000000001 bytes (0x00000001)
13:48:24.834694 http.c:744              => Send SSL data: .
13:48:24.834729 http.c:729              => Send SSL data, 0000000005 bytes (0x00000005)
13:48:24.834732 http.c:744              => Send SSL data: ....5
13:48:24.834734 http.c:729              => Send SSL data, 0000000001 bytes (0x00000001)
13:48:24.834737 http.c:744              => Send SSL data: .
13:48:24.834740 http.c:756              == Info: TLSv1.3 (OUT), TLS handshake, Finished (20):
13:48:24.834743 http.c:729              => Send SSL data, 0000000036 bytes (0x00000024)
13:48:24.834746 http.c:744              => Send SSL data: ... .s... f$.ak7^...{....v..@DH.....
13:48:24.834807 http.c:756              == Info: SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
13:48:24.834818 http.c:756              == Info: ALPN, server accepted to use http/1.1
13:48:24.834829 http.c:756              == Info: Server certificate:
13:48:24.834853 http.c:756              == Info:  subject: C=US; ST=California; L=San Francisco; O=GitHub, Inc.; CN=github.com
13:48:24.834861 http.c:756              == Info:  start date: Mar 25 00:00:00 2021 GMT
13:48:24.834866 http.c:756              == Info:  expire date: Mar 30 23:59:59 2022 GMT
13:48:24.834886 http.c:756              == Info:  subjectAltName: host "github.com" matched cert's "github.com"
13:48:24.834902 http.c:756              == Info:  issuer: C=US; O=DigiCert, Inc.; CN=DigiCert High Assurance TLS Hybrid ECC SHA256 2020 CA1
13:48:24.834912 http.c:756              == Info:  SSL certificate verify ok.
13:48:24.834982 http.c:729              => Send SSL data, 0000000005 bytes (0x00000005)
13:48:24.834986 http.c:744              => Send SSL data: .....
13:48:24.834991 http.c:729              => Send SSL data, 0000000001 bytes (0x00000001)
13:48:24.834993 http.c:744              => Send SSL data: .
13:48:24.835008 http.c:703              => Send header, 0000000210 bytes (0x000000d2)
13:48:24.835018 http.c:715              => Send header: HEAD /xpack-dev-tools/content.git/info/refs?service=git-upload-pack HTTP/1.1
13:48:24.835022 http.c:715              => Send header: Host: github.com
13:48:24.835024 http.c:715              => Send header: User-Agent: git/2.33.1
13:48:24.835027 http.c:715              => Send header: Accept: */*
13:48:24.835029 http.c:715              => Send header: Accept-Encoding: deflate, gzip
13:48:24.835032 http.c:715              => Send header: Pragma: no-cache
13:48:24.835034 http.c:715              => Send header: Git-Protocol: version=2
13:48:24.835037 http.c:715              => Send header:
13:48:24.901676 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.901713 http.c:744              <= Recv SSL data: ....J
13:48:24.901744 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.901751 http.c:744              <= Recv SSL data: .
13:48:24.901798 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
13:48:24.901809 http.c:729              <= Recv SSL data, 0000000057 bytes (0x00000039)
13:48:24.901815 http.c:744              <= Recv SSL data: ...5... .............. ...F..J.).C8.t.......@...........
13:48:24.901926 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.901934 http.c:744              <= Recv SSL data: ....J
13:48:24.901945 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.901951 http.c:744              <= Recv SSL data: .
13:48:24.901965 http.c:756              == Info: TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
13:48:24.901972 http.c:729              <= Recv SSL data, 0000000057 bytes (0x00000039)
13:48:24.901979 http.c:744              <= Recv SSL data: ...5... ..'........... (.h...a...........".W&.......*....
13:48:24.902004 http.c:756              == Info: old SSL session ID is stale, removing
13:48:24.902965 http.c:729              <= Recv SSL data, 0000000005 bytes (0x00000005)
13:48:24.902978 http.c:744              <= Recv SSL data: .....
13:48:24.902992 http.c:729              <= Recv SSL data, 0000000001 bytes (0x00000001)
13:48:24.902997 http.c:744              <= Recv SSL data: .
13:48:24.903055 http.c:756              == Info: Mark bundle as not supporting multiuse
13:48:24.903069 http.c:703              <= Recv header, 0000000033 bytes (0x00000021)
13:48:24.903083 http.c:715              <= Recv header: HTTP/1.1 405 Method Not Allowed
13:48:24.903093 http.c:703              <= Recv header, 0000000026 bytes (0x0000001a)
13:48:24.903099 http.c:715              <= Recv header: Server: GitHub Babel 2.0
13:48:24.903108 http.c:703              <= Recv header, 0000000026 bytes (0x0000001a)
13:48:24.903114 http.c:715              <= Recv header: Content-Type: text/plain
13:48:24.903123 http.c:703              <= Recv header, 0000000054 bytes (0x00000036)
13:48:24.903129 http.c:715              <= Recv header: Content-Security-Policy: default-src 'none'; sandbox
13:48:24.903157 http.c:703              <= Recv header, 0000000019 bytes (0x00000013)
13:48:24.903165 http.c:715              <= Recv header: Content-Length: 0
13:48:24.903173 http.c:703              <= Recv header, 0000000056 bytes (0x00000038)
13:48:24.903178 http.c:715              <= Recv header: X-GitHub-Request-Id: DCA0:2BC1:DE3692:18F8A6B:61A8B288
13:48:24.903186 http.c:703              <= Recv header, 0000000023 bytes (0x00000017)
13:48:24.903192 http.c:715              <= Recv header: X-Frame-Options: DENY
13:48:24.903213 http.c:756              == Info: The requested URL returned error: 405
13:48:24.903253 http.c:756              == Info: Closing connection 0
13:48:24.903281 http.c:729              => Send SSL data, 0000000005 bytes (0x00000005)
13:48:24.903287 http.c:744              => Send SSL data: .....
13:48:24.903292 http.c:729              => Send SSL data, 0000000001 bytes (0x00000001)
13:48:24.903298 http.c:744              => Send SSL data: .
13:48:24.903333 http.c:756              == Info: TLSv1.3 (OUT), TLS alert, close notify (256):
13:48:24.903347 http.c:729              => Send SSL data, 0000000002 bytes (0x00000002)
13:48:24.903353 http.c:744              => Send SSL data: ..
fatal: unable to access 'https://github.com/xpack-dev-tools/content.git/': The requested URL returned error: 405
ilg@xbbma tmp %
```

Runs fine when built with clang.

## 2021-12-01

The following packages require clang:

- pkg-config
- cmake
- python3

The problem is caused by the `const static` used as array size, feature not implemented by GCC.

## 2021-11-27

- rebuild for macOS 11.6
- update to GCC 11.2 also available from @iains/@fxcoudert

## 2021-11-14

- update most packages to latest releases
- most projects have out-of-date config.sub; overwrite with 2021-08-14 from
  <https://git.savannah.gnu.org/cgit/config.git/plain/config.sub>
- only GCC 11.1 is available for Apple Silicon, maintained by @iains
  <https://github.com/iains/gcc-darwin-arm64>

## 2021-11-11

- install xbbma with macOS 11.6.1
- receive Mac Mini from MacStadium
