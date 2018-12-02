Author: Roger Jang, 20140501, 20170501

music4db:
	There are 3 mp3 files of oldies

music4query:
	There are 2 recordings via my smartphone (HTC one).
	Speaker location: far and fixed
	Noise types: speech, tapping, clapping, scratching, electric fan, etc
	Recording device location: fixed
	Recognizable by human: Yes, most of the time.

AFP test results (Please refer to the example of afpPerfEval.m):

	For afpOpt=afpOptSet:
		Overall recognition rate: 96.7742%
		Total running time: 12.676025 sec
		Average retrieval time per query: 0.388874 sec
		1/2: Song name = AiPingCaiHuiYing_yeh.mp3, queryClipCount=10, accuracy=90%
		2/2: Song name = The Power Of Love_xxx.mp3, queryClipCount=21, accuracy=100%

	For afpOpt=afpOptSet0:
		Overall recognition rate: 90.3226%
		Total running time: 10.491795 sec
		Average retrieval time per query: 0.319037 sec
		1/2: Song name = AiPingCaiHuiYing_yeh.mp3, queryClipCount=10, accuracy=100%
		2/2: Song name = The Power Of Love_xxx.mp3, queryClipCount=21, accuracy=85.7143%