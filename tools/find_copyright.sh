#
fgrep --exclude=svn --exclude=.git --exclude=.repo --exclude=\*.java --exclude=\*.c --exclude=\*.cpp \
   --exclude=\*.cc --exclude=\*.sh --exclude=xx\* -i "copyright" -r . | \
   sed -e "/Binary file /d" -e "s/..//" -e "s/\//ZZ1234ZZ/" -e "s/\//ZZ1234ZZ/" -e "s/ZZ1234ZZ/\//" \
    -e "s/:/ZZ4321ZZ/" -e "s/ZZ1234ZZ.*ZZ4321ZZ/:/" -e "s/\/NOTICEZZ4321ZZ/:/" \
    -e "s/\/.*ZZ4321ZZ/:/" \
-e "/the above copyright/d" -e "/royalty-free copyright/d" \
-e "/Agreement is copyrighted/d" -e "/NSHumanReadableCopyright/d" \
-e "/to grant copyright/d" -e "/may be copyrighted/d" \
-e "/copyright info/d" -e "/copyright rights/d" -e "/copyright owner/d" \
-e "/copyright license/d" -e "/copyright notice/d" -e "/copyright holder/d" \
-e "/copyright statement/d" -e "/all copyright, patent/d" \
-e "/Grant of Copyright/d" -e "/COPYRIGHT OWNER/d" -e "/COPYRIGHT HOLDER/d" \
-e "/NO EVENT SHALL THE COPYRIGHT/d" -e "/Copyright Holder/d" \
-e "s/:.*Copyright.*SVOX AG.*/:SVOX/" \
-e "s/:.*Android Open[- ]Source Project.*/:AOSP/" -e "s/:.*android open source project.*/:AOSP/" \
-e "s/:.*The Android Open Project.*/:AOSP/" \
-e "s/:.*Chromium COPYRIGHT.*/:CHROMIUM/" -e "s/:.*Chromium Authors.*/:CHROMIUM/" \
-e "s/:.*Google.*/:GOOGLE/" \
-e "s/:.*Adobe System.*/:OSS/" \
-e "s/:.*Advanced Micro Devices.*/:OSS/" \
-e "s/:.*Analog Devices.*/:OSS/" \
-e "s/:.*Apple.*/:OSS/" \
-e "s/\/mksh:.*primary author.*/\/mksh:OSS/" \
-e "s/:.*ARM Limited.*/:OSS/" \
-e "s/:.*ARM Ltd.*/:OSS/" \
-e "s/:.*Atheros Communications.*/:OSS/" \
-e "s/:.*Atmel.*/:OSS/" \
-e "s/:.*AT&T.*/:OSS/" \
-e "s/:.*Australian National University.*/:OSS/" \
-e "s/:.*Borland.*/:OSS/" \
-e "s/:.*Broadcom.*/:OSS/" \
-e "s/:.*Carnegie Mellon.*/:OSS/" \
-e "s/:.*Cisco.*/:OSS/" \
-e "s/:.*Code Aurora Forum.*/:OSS/" \
-e "s/:.*CodeSourcery.*/:OSS/" \
-e "s/:.*Collabora Ltd.*/:OSS/" \
-e "s/:.*Commonwealth Scientific and Industrial Research.*/:OSS/" \
-e "s/:.*Company 100 Inc.*/:OSS/" \
-e "s/:.*Compaq.*/:OSS/" \
-e "s/:.*Computer Systems and Communication Lab.*/:OSS/" \
-e "s/:.*Concurrent Computer.*/:OSS/" \
-e "s/:.*Conectiva S.A..*/:OSS/" \
-e "s/:.*Copyright.*Bjorn Reese.*/:OSS/" \
-e "s/:.*Copyright.*Brian Swetland.*/:OSS/" \
-e "s/:.*copyright.*by David Turner.*/:OSS/" \
-e "s/:.*[Cc]opyright.*Christian Werner.*/:OSS/" \
-e "s/:.*Copyright.*Cibu Johny.*/:OSS/" \
-e "s/:.*Copyright.*Colin Percival.*/:OSS/" \
-e "s/:.*Copyright.*Damien Miller.*/:OSS/" \
-e "s/:.*Copyright.*Embedded Unit Project.*/:OSS/" \
-e "s/:.*Copyright.*Eric S. Raymond.*/:OSS/" \
-e "s/:.*Copyright.*Josh Coalson.*/:OSS/" \
-e "s/:.*Copyright.*John Graham-Cumming.*/:OSS/" \
-e "s/:.*Copyright.*Junio C Hamano.*/:OSS/" \
-e "s/:.*Copyright.*Jutta Degener.*/:OSS/" \
-e "s/:.*Copyright.*Julian Seward.*/:OSS/" \
-e "s/:.*Copyright.*Kungliga Tekniska.*/:OSS/" \
-e "s/:.*[Cc]opyright.*Lee Thomason.*/:OSS/" \
-e "s/:.*Copyright.*Michael Pruett.*/:OSS/" \
-e "s/:.*Copyright.*Oleg Mazurov.*/:OSS/" \
-e "s/:.*Copyright.*Paul Kranenburg.*/:OSS/" \
-e "s/:.*Copyright.*Ryan Lienhart Dahl.*/:OSS/" \
-e "s/:.*Copyright.*Shigeru Chiba.*/:OSS/" \
-e "s/:.*Copyright.*Steven J. Ross.*/:OSS/" \
-e "s/:.*Copyright.*Vlad Roubtsov.*/:OSS/" \
-e "s/:.*Copyright.*Will Drewry.*/:OSS/" \
-e "s/:.*Copyright.*Wolfgang Solfrank.*/:OSS/" \
-e "s/:.*Copyright.*ZXing authors.*/:OSS/" \
-e "s/:.*CORE SDI S.A.*/:OSS/" \
-e "s/:.*Cray.*/:OSS/" \
-e "s/:.*Crynwr Software.*/:OSS/" \
-e "s/:.*CSIRO.*/:OSS/" \
-e "s/:.*CSR Ltd.*/:OSS/" \
-e "s/:.*Data General Corporation.*/:OSS/" \
-e "s/:.*Devicescape Software Inc.*/:OSS/" \
-e "s/:.*Digital Equipment Corporation.*/:OSS/" \
-e "s/:.*Ericsson AB.*/:OSS/" \
-e "s/:.*Expat maintainers.*/:OSS/" \
-e "s/:.*Fraunhofer.*/:OSS/" \
-e "s/:.*Free Software Foundation.*/:OSS/" \
-e "s/:.*GNOME FOUNDATION.*/:OSS/" \
-e "s/:.*Hewlett[- ]Packard.*/:OSS/" \
-e "s/:.*IBM.*/:OSS/" \
-e "s/:.*idnconnect.jdna.jp.*/:OSS/" \
-e "s/:.*Id Software.*/:OSS/" \
-e "s/:.*Igalia.*/:OSS/" \
-e "s/:.*Imagination Technologies.*/:OSS/" \
-e "s/:.*INRIA France Telecom.*/:OSS/" \
-e "s/:.*Intel Corp.*/:OSS/" \
-e "s/:.*International Business Machines.*/:OSS/" \
-e "s/:.*Internet Software Consortium.*/:OSS/" \
-e "s/:.*Internet Systems Consortium.*/:OSS/" \
-e "s/:.*InvenSense.*/:OSS/" \
-e "s/:.*JMonkeyEngine.*/:OSS/" \
-e "s/:.*JSR305 expert group.*/:OSS/" \
-e "s/:.*Legion Of The Bouncy Castle.*/:OSS/" \
-e "s/:.*LibreSoft Universidad.*/:OSS/" \
-e "s/:.*LightSys Technology Services Inc.*/:OSS/" \
-e "s/:.*Linux Foundation.*/:OSS/" \
-e "s/:.*Linux International.*/:OSS/" \
-e "s/:.*Lohit Fonts Project.*/:OSS/" \
-e "s/:.*Lotus Development Corporation.*/:OSS/" \
-e "s/:.*Lucent Technologies.*/:OSS/" \
-e "s/:.*LunarG Inc.*/:OSS/" \
-e "s/:.*Massachusetts Institute of.*/:OSS/" \
-e "s/:.*Microsoft Corp.*/:OSS/" \
-e "s/:.*mime4j project.*/:OSS/" \
-e "s/:.*MIPS Technologies Inc.*/:OSS/" \
-e "s/:.*MIT Licence.*/:OSS/" \
-e "s/:.*MontaVista.*/:OSS/" \
-e "s/:.*Motorola.*/:OSS/" \
-e "s/:.*Mozilla.*/:OSS/" \
-e "s/:.*National Electronics and Computer Technology Center.*/:OSS/" \
-e "s/:.*National ICT Australia.*/:OSS/" \
-e "s/:.*NetBSD Foundation.*/:OSS/" \
-e "s/:.*Netfilter Core Team.*/:OSS/" \
-e "s/:.*Netscape Communications Corporation.*/:OSS/" \
-e "s/:.*Nokia.*/:OSS/" \
-e "s/:.*North Dakota State University.*/:OSS/" \
-e "s/:.*Novell.*/:OSS/" \
-e "s/:.*Nuance.*/:OSS/" \
-e "s/:.*NVIDIA.*/:OSS/" \
-e "s/:.*NXP.*/:OSS/" \
-e "s/:.*Olivetti.*/:OSS/" \
-e "s/:.*OMRON.*/:OSS/" \
-e "s/:.*OpenedHand.*/:OSS/" \
-e "s/:.*OpenMoko Inc.*/:OSS/" \
-e "s/:.*OpenVision Technologies.*/:OSS/" \
-e "s/:.*OpenVPN Technologies Inc.*/:OSS/" \
-e "s/:.*OpenWorks .*/:OSS/" \
-e "s/:.*Oracle.*/:OSS/" \
-e "s/:.*PacketVideo.*/:OSS/" \
-e "s/:.*Purdue Research.*/:OSS/" \
-e "s/:.*Python Markdown Project.*/:OSS/" \
-e "s/:.*Qualcomm.*/:OSS/" \
-e "s/:.*QUALCOMM.*/:OSS/" \
-e "s/:.*Quarterdeck.*/:OSS/" \
-e "s/:.*Red Hat.*/:OSS/" \
-e "s/:.*Regents of the University of.*/:OSS/" \
-e "s/:.*Renesas Technology.*/:OSS/" \
-e "s/:.*Research [iI]n Motion.*/:OSS/" \
-e "s/:.*RSA Data Security.*/:OSS/" \
-e "s/:.*Samsung.*/:OSS/" \
-e "s/:.*Silicon Graphics.*/:OSS/" \
-e "s/:.*Software AG.*/:OSS/" \
-e "s/:.*Sony.*/:OSS/" \
-e "s/:.*Sonic Network.*/:OSS/" \
-e "s/:.*Speechworks.*/:OSS/" \
-e "s/:.*ST Ericsson.*/:OSS/" \
-e "s/:.*STMicroelectronics.*/:OSS/" \
-e "s/:.*Student Information Processing.*/:OSS/" \
-e "s/:.*Sun Microsystems.*/:OSS/" \
-e "s/:.*S[Uu]SE.*/:OSS/" \
-e "s/:.*Symantec.*/:OSS/" \
-e "s/:.*Temporal Wave.*/:OSS/" \
-e "s/:.*Texas Instruments.*/:OSS/" \
-e "s/:.*Thai Open Source Software Center.*/:OSS/" \
-e "s/:.*The ANGLE Project Authors.*/:OSS/" \
-e "s/:.*The Apache Software.*/:OSS/" \
-e "s/:.*The Dojo Foundation.*/:OSS/" \
-e "s/:.*The Flex Project.*/:OSS/" \
-e "s/:.*The GNOME.*/:OSS/" \
-e "s/:.*The Guava Authors.*/:OSS/" \
-e "s/:.*The Khronos Group.*/:OSS/" \
-e "s/:.*The LibYuv project authors.*/:OSS/" \
-e "s/:.*The OpenBSD project.*/:OSS/" \
-e "s/:.*The Open Group.*/:OSS/" \
-e "s/:.*The Perl Foundation.*/:OSS/" \
-e "s/:.*The RE2 Authors.*/:OSS/" \
-e "s/:.*The TCPDUMP project.*/:OSS/" \
-e "s/:.*The WebKitGTK.*/:OSS/" \
-e "s/:.*The WebM project.*/:WEBM/" \
-e "s/:.*WebRTC project authors.*/:WEBRTC/" \
-e "s/:.*The Xiph.Org Foundation.*/:OSS/" \
-e "s/:.*Torch Mobile.*/:OSS/" \
-e "s/:.*Tresys Technology LLC.*/:OSS/" \
-e "s/:.*Trolltech.*/:OSS/" \
-e "s/:.*Trusted Computer Solutions.*/:OSS/" \
-e "s/:.*Trusted Logic.*/:OSS/" \
-e "s/:.*Unicode Inc.*/:OSS/" \
-e "s/:.*United States Government.*/:OSS/" \
-e "s/:.*University of Cambridge.*/:OSS/" \
-e "s/:.*University of Illinois.*/:OSS/" \
-e "s/:.*University of Manchester.*/:OSS/" \
-e "s/:.*University of Szeged.*/:OSS/" \
-e "s/:.*V8 project authors.*/:OSS/" \
-e "s/:.*VA Linux Systems.*/:OSS/" \
-e "s/:.*VMware Inc.*/:OSS/" \
-e "s/:.*Vrije Universiteit.*/:OSS/" \
-e "s/:.*WIDE Project.*/:OSS/" \
-e "s/:.*World Wide Web.*/:OSS/" \
-e "s/:.*X Consortium.*/:OSS/" \
-e "s/:.*XFree86.*/:OSS/" \
-e "s/:.*Xiph.org Foundation.*/:OSS/" \
-e "s/:.*X.Org Foundation.*/:OSS/" \
    | sort -u >xx.tmp
grep ":OSS$" xx.tmp | sed -e "/:Copyright/d" -e "s/ /-/g" -e "/\.repo/d" -e "s/:OSS$//" -e "s/\//\\\\\//g" -e "s/.*/\/&\/s\/:.*[Cc][Oo][Pp][Yy][rR][Ii][Gg][Hh][Tt].*\/:OSS\//" >xx.sed
sed -f xx.sed < xx.tmp | sort -u

#-e "/prebuilt\//d" -e "/prebuilts\//d" \