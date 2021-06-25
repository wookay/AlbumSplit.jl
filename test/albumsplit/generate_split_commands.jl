module test_albumsplit_generate_split_commands

using Test
using AlbumSplit
using Dates

filepath = "거북이 노래 모음-SIcHPs-Qszc.mp3"
duration = Time(0, 10, 45, 999)
artist = "거북이"
tracks = """
00:01   빙고
03:10   비행기
06:42   사계
"""
cmds = AlbumSplit.get_split_commands(filepath, artist, tracks; duration)
@test first(cmds) == """ffmpeg -i "거북이 노래 모음-SIcHPs-Qszc.mp3" -ss 00:00:01 -to 00:03:09.999 "거북이 - 1 빙고.mp3\""""

many_tracks = """
0:00:01   빙고
0:03:10   비행기
0:06:42   사계
0:10:46   왜이래
0:13:55   싱랄라
0:17:05   Come On
0:20:37   얼마나
0:24:04   어깨쫙
0:27:16   혼자가 아니야
0:30:24   주인공
0:33:45   아이고
0:36:53   나는
0:40:25   그대 내 맘에 들어오면은
0:44:06   장군에게
0:48:25   순한 사랑
0:52:43   향기로운 추억
0:56:50   변해가네
1:00:29   왜 말 안했니
1:03:49   고맙습니다
1:07:35   My Name
1:10:54   내가 너라면
1:14:13   오방간다
1:15:48   Real Love
1:19:55   아지와 양이
1:23:34   사랑하는 그대여
1:27:45   Let's 거북이
1:31:43   이제부터
1:35:13   놀리지마
1:38:29   나 어때
1:42:04   인간이 되라
1:45:37   그렇지 않아
1:49:21   거북이 걸음
1:53:01   비 오는 날
1:57:18   수호천사
2:01:01   흔들림
2:04:30   못말리는 결혼
2:07:37   그러길 바래
2:11:13   깎아주세요
2:14:43   그러길 바래
2:18:42   10시04분
"""
cmds = AlbumSplit.get_split_commands(filepath, artist, many_tracks; duration)
@test first(cmds) == """ffmpeg -i "거북이 노래 모음-SIcHPs-Qszc.mp3" -ss 00:00:01 -to 00:03:09.999 "거북이 - 01 빙고.mp3\""""


end # module test_albumsplit_generate_split_commands
