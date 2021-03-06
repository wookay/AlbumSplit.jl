# module AlbumSplit

using Dates
using FFMPEG

struct Track
    title::String
    start_timestamp::Time
    end_timestamp::Time
end

function parse_time_title(line::String)::Union{Nothing, Tuple{Time, String}}
    regex_hms2 = r"(?<lhs>.*)(?<time>([\d]{2}:[\d]{2}:[\d]{2}))(?<rhs>.*)"
    regex_ms2  = r"(?<lhs>.*)(?<time>([\d]{2}:[\d]{2}))(?<rhs>.*)"
    regex_hms1 = r"(?<lhs>.*)(?<time>([\d]{1}:[\d]{2}:[\d]{2}))(?<rhs>.*)"
    regex_ms1  = r"(?<lhs>.*)(?<time>([\d]{1}:[\d]{2}))(?<rhs>.*)"
    for regex in (regex_hms2, regex_ms2, regex_hms1, regex_ms1)
        m = match(regex, line)
        if m isa RegexMatch
            if !isempty(m[:lhs]) && isempty(m[:rhs])
                title = rstrip(m[:lhs])
            else
                title = lstrip(m[:rhs])
            end
            if regex === regex_ms2
                t = parse(Time, string("00:", m[:time]))
            elseif regex === regex_ms1
                t = parse(Time, string("00:0", m[:time]))
            else
                t = parse(Time, m[:time])
            end
            return (t, title)
        end
    end
    return nothing
end

function get_track_title(idx, len, old_title)
    idx_dot_space = string(idx, ". ")
    idx_zerolpad = lpad(idx, ndigits(len), '0')
    idx_zerolpad_space =  string(idx_zerolpad, ' ')
    idx_space = string(idx, ' ')
    if startswith(old_title, idx_dot_space)
        title = old_title[length(idx_dot_space)+1:end]
    elseif startswith(old_title, idx_zerolpad_space)
        title = old_title[length(idx_zerolpad_space)+1:end]
    elseif startswith(old_title, idx_space)
        title = old_title[length(idx_space)+1:end]
    else
        title = old_title
    end
    string(idx_zerolpad, ' ', title)
end

function get_artist_title(artist::String, title::String)::String
    isempty(artist) ? title : string(artist, " - ", title)
end

function make_tracks(duration::Time, artist::String, trackstr::String)::Vector{Track}
    list = Tuple{Time, String}[]
    for line in eachline(IOBuffer(trackstr))
        time_title = parse_time_title(line)
        time_title isa Tuple{Time, String} && push!(list, time_title)
    end
    len = length(list)
    if iszero(len)
        return Track[]
    elseif isone(len)
        (start_timestamp, title) = first(list)
        end_timestamp = duration
        artist_title = get_artist_title(artist, title)
        return [Track(artist_title, start_timestamp, end_timestamp)]
    else
        last_idx = lastindex(list)
        tracks = Vector{Track}()
        for (idx, (start_timestamp, title)) in enumerate(list)
            if last_idx == idx
               end_timestamp = duration
            else
               end_timestamp = first(list[idx + 1]) - Millisecond(1)
            end
            artist_num_title = get_artist_title(artist, get_track_title(idx, len, title))
            push!(tracks, Track(artist_num_title, start_timestamp, end_timestamp))
        end
        return tracks
    end
end

function timeparse(str)
    dot = findfirst('.', str)
    if dot !== nothing
        rest = str[dot+1:end]
        len = length(rest)
        if len >= 4
            (us, _) = Dates.tryparsenext_base10(rest, 4, len, 1, 3)
            return parse(Time, str[1:dot+3]) + Microsecond(us)
        end
    end
    parse(Time, str)
end

function get_duration(filepath::String)::Time
    cmd = `-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$filepath"`
    (duration,) = FFMPEG.exe(cmd, command=FFMPEG.ffprobe, collect=true)
    timeparse(duration)
end

function get_split_commands(filepath::String, artist::String, trackstr::String; duration::Union{Nothing, Time} = nothing, file_extension=".mp3")::Vector{String}
    if isnothing(duration)
        if isfile(filepath)
            duration::Time = get_duration(filepath)
        else
            throw(ArgumentError("no such file: $filepath"))
        end
    end
    cmds = Vector{String}()
    for track in make_tracks(duration, artist, trackstr)
        output = string(track.title, file_extension)
        cmd = """ffmpeg -i "$filepath" -ss $(track.start_timestamp) -to $(track.end_timestamp) "$output\""""
        push!(cmds, cmd)
    end
    cmds
end

function generate_split_commands(args...; kwargs...)
    println.(get_split_commands(args...; kwargs...))
end

# module AlbumSplit
