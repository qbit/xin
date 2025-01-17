{ pkgs, ... }:
let
  yamlFmt = pkgs.formats.yaml { };
  beetConfig = {
    directory = "/home/qbit/Music";
    "import" = {
      write = true;
      copy = true;
      autotag = true;
      timid = false;
      resume = "ask";
      incremental = "no";
      none_rec_action = "ask";
      log = null;
      quiet = "no";
      quiet_fallback = "skip";
      default_action = "apply";
      singletons = "no";
      languages = [ ];
      detail = "no";
      flat = "no";
    };
    original_date = true;
    per_disc_numbering = "no";
    clutter = [ "Thumbs.DB" ".DS_Store" "*.m3u" ".pls" "*.jpg" ];
    ignore = [ ".*" "*~" "System Volume Information" ];
    threaded = true;
    timeout = 5;
    verbose = 0;
    color = "no";
    list_format_item = "%upper{$artist} - $album - $track. $title";
    list_format_album = "%upper{$albumartist} - $album";
    time_format = "%Y-%m-%d %H:%M:%S";
    terminal_encoding = "utf8";
    ui = {
      terminal_width = 80;
      length_diff_thresh = 10;
    };
    match = {
      strong_rec_thresh = 0.1;
      medium_rec_thresh = 0.25;
      rec_gap_thresh = 0.25;
      max_rec = {
        missing_tracks = "medium";
        unmatched_tracks = "medium";
      };
      distance_weights = {
        source = 2;
        artist = 3;
        album = 3;
        media = 1;
        mediums = 1;
        year = 1;
        country = 0.5;
        label = 0.5;
        catalognum = 0.5;
        albumdisambig = 0.5;
        album_id = 5;
        tracks = 2;
        missing_tracks = 0.9;
        unmatched_tracks = 0.6;
        track_title = 3;
        track_artist = 2;
        track_index = 1;
        track_length = 2;
        track_id = 5;
      };
      preferred = {
        countries = [ ];
        media = [ ];
        original_year = "no";
      };
      ignored = [ ];
      track_length_grace = 10;
      track_length_max = 30;
    };
    plugins = [
      "discogs"
      "duplicates"
      "embedart"
      "fetchart"
      "inline"
      "lastgenre"
      "lyrics"
      "mbsync"
      "missing"
      "scrub"
      "smartplaylist"
      "web"
      "permissions"
    ];
    item_fields = {
      albumartist_no_space = ''albumartist.replace(" ", "_")'';
      genre_no_space = ''genre.replace(" ", "_")'';
    };
    lyrics = {
      auto = true;
      fallback = "";
    };
    fetchart = {
      auto = true;
      maxwidth = 300;
      cautious = true;
      cover_names = "cover folder";
    };
    embedart = {
      auto = true;
      maxwidth = 300;
    };
    replaygain = {
      auto = true;
      overwrite = true;
      albumgain = true;
    };
    scrub = { auto = true; };
    lastgenre = {
      whitelist = "~/.config/beets/genres.txt";
      canonical = "~/.config/beets/genres-tree.yaml";
    };
    smartplaylist = {
      relative_to = "/home/qbit/Music";
      playlist_dir = "/home/qbit/Playlists/";
      playlists = [
        {
          name = "all.m3u";
          query = "";
        }
        {
          name = "hiphop.m3u";
          query = "genre:hip hop";
        }
        {
          name = "tool.m3u";
          query = "artist:Tool year+";
        }
        {
          name = "metal.m3u";
          query = "genre:metal";
        }
        {
          name = "blues.m3u";
          query = "genre:blues";
        }
        {
          name = "bluegrass.m3u";
          query = "genre:bluegrass";
        }
        {
          query = [ "genre+" ];
          name = "%asciify{$genre_no_space}.m3u";
        }
      ];
    };
    mpdstats = {
      rating = "False";
      rating_mix = 0.75;
    };
    missing = {
      format = "$albumartist - $album - $track - $title";
      count = false;
      total = false;
    };
    permissions = {
      file = 644;
      dir = 755;
    };
    library = "~/.musiclibrary.blb";
  };
  beetConfigFile = yamlFmt.generate "config.yaml" beetConfig;
in
{
  config = {
    environment.etc."beets/config.ini".text = builtins.readFile beetConfigFile;
  };
}
