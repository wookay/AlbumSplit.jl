module test_albumsplit_generate_split_commands

using Test
using AlbumSplit # generate_split_commands
using Dates

time, title = AlbumSplit.parse_time_title("03:10   비행기")
@test time == Dates.Time(0, 3, 10)
@test title == "비행기"

time, title = AlbumSplit.parse_time_title("3:10   비행기")
@test time == Dates.Time(0, 3, 10)

time, title = AlbumSplit.parse_time_title("In The End 22:07")
@test time == Dates.Time(0, 22, 7)
@test title == "In The End"

time, title = AlbumSplit.parse_time_title("test 2:03")
@test time == Dates.Time(0, 2, 3)

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
@test cmds[2]     == """ffmpeg -i "거북이 노래 모음-SIcHPs-Qszc.mp3" -ss 00:03:10 -to 00:06:41.999 "거북이 - 2 비행기.mp3\""""

filepath = "Linkin Park - Hybrid Theory.mp3"
duration = Time(0, 37, 51, 999)
artist = "Linkin Park"
many_tracks = """
Papercut 0:00
One Step Closer 3:04
With You 5:40
Points Of Authority 9:03
Crawling 12:23
Runaway 15:53
By Myself 18:57
In The End 22:07
A Place For My Head 25:43
Forgotten 28:47
Cure For The Itch 32:03
Pushing Me Away 34:39
"""
cmds = AlbumSplit.get_split_commands(filepath, artist, many_tracks; duration)
@test cmds[8] == """ffmpeg -i "Linkin Park - Hybrid Theory.mp3" -ss 00:22:07 -to 00:25:42.999 "Linkin Park - 08 In The End.mp3\""""

end # module test_albumsplit_generate_split_commands
