Class rccjs.WSockNodeJs [ Not ProcedureBlock ]
{

/// manage data for Websocket by Global ^ZSocketRun
///  0 = Pause
///  1 = Process Input
/// -1 = Exit Client
ClassMethod Run()
{
	write !!,"*** Welcome to WebSocket by Node.js Native API Demo ***",!!
	do ..Start()
#; prepare next run	
	while (^ZSocketRun>=0) {
		do selsrv quit:$t
N		do text,control 
		goto @ctrl 
S		do listen,control 
		goto @ctrl
E		continue

X		do ..Stop()
Z		quit		 
	}
	quit

listen
	for  {
		set top=+$g(^ZSocketOut(0))
		if top write !,"******* "_top_" Replies *******",! 
		for n=1:1:top {
			write n,?5,$g(^ZSocketOut(n)),!
		}
		if (top<^ZSocketIn(0)) {
			read x#1:5 
			if x'="*" continue
			}
		quit
		}
	quit
	
control
	write !!,"Select action for WebClient Service",!
		,"New EchoServer (E), New Text(N), Send+Listen(S)",!
		,"Show Log (L), Exit+Stop WsClient(X)"
	read " [S] :",ctrl
	set ctrl=$e($zcvt(ctrl,"U"))
	if "ESNXL"'[ctrl goto control
	set ctrl=$e($zcvt(ctrl,"U"))
	if ctrl="" set ctrl="S" write "S"
	write !,"%%%%%%%%%%%%%%%%%%%%%%%%%%",!
	if ctrl="L" {
		do $ZF(-1,"cat wsock.log") 
		write !  goto control
		}
	set ^ZSocketRun=$s(ctrl="Z":-1,ctrl="S":1,1:0)
	quit 			

selsrv
	set server(1)="ws://echo.websocket.org/"
	set server(2)="--- server 2 ----"
	set server(3)="--- server 3 ----"
	write !,"Known Hosts (*=Exit) [1]:",!
	for i=1:1:3 write i,?3,server(i),!
	read "select (1): ",srv
	if srv="*" quit
	if 'srv ; fix for demo
			set srv=1 
	write " ==> ",server(srv),!,"#",!
	set ^ZSocketIn=server(srv)	
		,^ZSocketRun(0)=server(srv)
	if 0	
	quit

text
	write "Enter text to get echoed from WebSocketClient Service",!,
		"Terminate with * at first position",!,
		"or get generated text by %",!,
		"or append new text with @",! 
	for n=1:1 {
		write !,n,?5 read line quit:$e(line)="*"
		if $e(line)="@" {
			set n=^ZSocketIn(0)
			continue
		}   
		if $e(line)="%" {
			do lorem 
			set (fm,to)=0
			for n=n:1 {
				set fm=to+1
					,to=fm+20+$r(40)
					,sp=$find(lorem," ",to)-1
					,to=$s(sp>to:sp,1:to)
					,line=$e(lorem,fm,to)
					,^ZSocketIn(n)=line
				write !,n,?5,"* ",line
				quit:to>=$l(lorem)
				}
			continue
		}
		set ^ZSocketIn(n)=line_$c(160)
	}
	set ^ZSocketIn(0)=n-1
	kill ^ZSocketOut
    quit

lorem
	set lorem="Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy "_
			"nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. "_
			"Ut wisi enim ad minim veniam, quis nostrud exercitation ulliam corper "_
			"suscipit lobortis nisl ut aliquip ex ea commodo consequat. "_
			"Duis autem veleum iriure dolor in hendrerit in vulputate velit esse molestie "_
			"consequat, vel willum lunombro dolore eu feugiat nulla facilisis at vero "_
			"eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril "_
			"delenit augue duis dolore te feugait nulla facilisi. "_
			"Li Europan lingues es membres del sam familie. "_
			"Lor separat existentie es un myth. Por scientie, musica, sport etc., "_
			"li tot Europa usa li sam vocabularium. Li lingues differe solmen in li grammatica, "_
			"li pronunciation e li plu commun vocabules. Omnicos directe al desirabilit… "_
			"de un nov lingua franca: on refusa continuar payar custosi traductores. "_
			"It solmen va esser necessi far uniform grammatica, pronunciation e plu sommun "_
			"paroles. Ma quande lingues coalesce, li grammatica del resultant lingue es "_
			"plu simplic e regulari quam ti del coalescent lingues. Li nov lingua franca "_
			"va esser plu simplic e regulari quam li existent Europan lingues. "_
			"It va esser tam simplic quam Occidental: in fact, it va esser Occidental. "_
			"A un Angleso it va semblar un simplificat Angles, quam un skeptic Cambridge "_
			"amico dit me que Occidental es."
	quit
}

/// kick nodes service	
ClassMethod Start()
{
    do $system.License.Login("_SYSTEM")
    set required="websocket"
		,libdir=$system.Util.InstallDirectory()_"lib"
    if '$d(^node.js(required)) {
	    do $zf(-1,"cd "_libdir_"/js/ && npm install websocket")
	    set ^node.js(required)=""
    }
	set ^ZSocketRun=0	
	do $zf(-100,"/ASYNC/STDOUT=wsock.log","node",libdir_"/js/WsockIris.js")
	write "********* Node.js process id = "_$ZC_"  *********",!
	quit
}
/// stop node service and release
ClassMethod Stop()
{
	set ^ZSocketRun=-1
	hang 5
	set ^ZSocketRun=0
	quit
}

}
