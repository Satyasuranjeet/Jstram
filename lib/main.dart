import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: SongListScreen(),
    );
  }
}

class Song {
  final String id;
  final String name;
  final String type;
  final String year;
  final int duration;
  final String language;
  final String url;
  final List<ImageItem> images;
  final List<DownloadUrl> downloadUrls;
  final AlbumInfo album;
  final ArtistInfo artists;

  Song({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.duration,
    required this.language,
    required this.url,
    required this.images,
    required this.downloadUrls,
    required this.album,
    required this.artists,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    // Parse images
    List<ImageItem> imagesList = [];
    if (json['image'] != null) {
      imagesList = (json['image'] as List)
          .map((imageData) => ImageItem.fromJson(imageData))
          .toList();
    }

    // Parse download URLs
    List<DownloadUrl> downloadUrlsList = [];
    if (json['downloadUrl'] != null) {
      downloadUrlsList = (json['downloadUrl'] as List)
          .map((urlData) => DownloadUrl.fromJson(urlData))
          .toList();
    }

    // Parse album info
    AlbumInfo albumInfo = AlbumInfo(id: '', name: 'Unknown Album', url: '');
    if (json['album'] != null) {
      albumInfo = AlbumInfo.fromJson(json['album']);
    }

    // Parse artist info
    ArtistInfo artistInfo = ArtistInfo(
      primary: [],
      featured: [],
    );
    if (json['artists'] != null) {
      artistInfo = ArtistInfo.fromJson(json['artists']);
    }

    return Song(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Title',
      type: json['type'] ?? 'song',
      year: json['year']?.toString() ?? 'Unknown Year',
      duration: json['duration'] ?? 0,
      language: json['language'] ?? 'Unknown',
      url: json['url'] ?? '',
      images: imagesList,
      downloadUrls: downloadUrlsList,
      album: albumInfo,
      artists: artistInfo,
    );
  }

  // Helper getter for thumbnail URL
  String? get thumbnailUrl {
    if (images.isNotEmpty) {
      // Try to get the medium size image first
      for (var image in images) {
        if (image.quality == '150x150') {
          return image.url;
        }
      }
      // Fallback to the first available image
      return images.first.url;
    }
    return null;
  }

  // Helper getter for MP3 URL
  String? get mp3Url {
    if (downloadUrls.isNotEmpty) {
      // Try to get the high quality URL first
      for (var url in downloadUrls) {
        if (url.quality == '320kbps') {
          return url.url;
        }
      }
      // Fallback to the first available URL
      return downloadUrls.first.url;
    }
    return null;
  }

  // Helper getter for artist names
  String get artistNames {
    if (artists.primary.isNotEmpty) {
      return artists.primary.map((artist) => artist.name).join(', ');
    }
    return 'Unknown Artist';
  }

  String get formattedDuration {
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Convert Song to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'year': year,
      'duration': duration,
      'language': language,
      'url': url,
      'image': images.map((image) => image.toJson()).toList(),
      'downloadUrl': downloadUrls.map((url) => url.toJson()).toList(),
      'album': album.toJson(),
      'artists': artists.toJson(),
    };
  }
}

class ImageItem {
  final String quality;
  final String url;

  ImageItem({required this.quality, required this.url});

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      quality: json['quality'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
    };
  }
}

class DownloadUrl {
  final String quality;
  final String url;

  DownloadUrl({required this.quality, required this.url});

  factory DownloadUrl.fromJson(Map<String, dynamic> json) {
    return DownloadUrl(
      quality: json['quality'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
    };
  }
}

class AlbumInfo {
  final String id;
  final String name;
  final String url;

  AlbumInfo({required this.id, required this.name, required this.url});

  factory AlbumInfo.fromJson(Map<String, dynamic> json) {
    return AlbumInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Album',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}

class Artist {
  final String id;
  final String name;
  final String role;
  final List<ImageItem>? images;
  final String type;
  final String url;

  Artist({
    required this.id,
    required this.name,
    required this.role,
    this.images,
    required this.type,
    required this.url,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    List<ImageItem>? imagesList;
    if (json['image'] != null) {
      imagesList = (json['image'] as List)
          .map((imageData) => ImageItem.fromJson(imageData))
          .toList();
    }

    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Artist',
      role: json['role'] ?? '',
      images: imagesList,
      type: json['type'] ?? 'artist',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'image': images?.map((image) => image.toJson()).toList(),
      'type': type,
      'url': url,
    };
  }
}

class ArtistInfo {
  final List<Artist> primary;
  final List<Artist> featured;

  ArtistInfo({required this.primary, required this.featured});

  factory ArtistInfo.fromJson(Map<String, dynamic> json) {
    List<Artist> primaryArtists = [];
    if (json['primary'] != null) {
      primaryArtists =
          (json['primary'] as List).map((e) => Artist.fromJson(e)).toList();
    }

    List<Artist> featuredArtists = [];
    if (json['featured'] != null) {
      featuredArtists =
          (json['featured'] as List).map((e) => Artist.fromJson(e)).toList();
    }

    return ArtistInfo(
      primary: primaryArtists,
      featured: featuredArtists,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary.map((artist) => artist.toJson()).toList(),
      'featured': featured.map((artist) => artist.toJson()).toList(),
    };
  }
}

// Playlist manager for handling playlist operations
class PlaylistManager {
  static const String _playlistKey = 'user_playlist';
  List<Song> _playlist = [];

  // Singleton pattern
  static final PlaylistManager _instance = PlaylistManager._internal();
  factory PlaylistManager() => _instance;
  PlaylistManager._internal();

  List<Song> get playlist => _playlist;

  // Load playlist from SharedPreferences
  Future<void> loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistJson = prefs.getString(_playlistKey);

    if (playlistJson != null) {
      final List<dynamic> decodedList = json.decode(playlistJson);
      _playlist = decodedList.map((item) => Song.fromJson(item)).toList();
    }
  }

  // Save playlist to SharedPreferences
  Future<void> savePlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList =
        json.encode(_playlist.map((song) => song.toJson()).toList());
    await prefs.setString(_playlistKey, encodedList);
  }

  // Add song to playlist
  Future<void> addSong(Song song) async {
    // Check if song already exists in playlist
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      await savePlaylist();
    }
  }

  // Remove song from playlist
  Future<void> removeSong(String songId) async {
    _playlist.removeWhere((song) => song.id == songId);
    await savePlaylist();
  }

  // Check if song is in playlist
  bool isSongInPlaylist(String songId) {
    return _playlist.any((song) => song.id == songId);
  }

  // Clear the entire playlist
  Future<void> clearPlaylist() async {
    _playlist.clear();
    await savePlaylist();
  }
}

// Audio Player manager for handling music playback
class AudioPlayerManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Song> _currentQueue = [];
  int _currentIndex = -1;

  // Singleton pattern
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal() {
    _init();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get queue => _currentQueue;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _currentQueue.length
          ? _currentQueue[_currentIndex]
          : null;

  Future<void> _init() async {
    // Configure the audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  // Play a single song
  Future<void> playSong(Song song) async {
    _currentQueue.clear();
    _currentQueue.add(song);
    _currentIndex = 0;
    await _loadAndPlayCurrent();
  }

  // Play a queue of songs starting from a specific index
  Future<void> playQueue(List<Song> songs, int initialIndex) async {
    _currentQueue.clear();
    _currentQueue.addAll(songs);
    _currentIndex = initialIndex;
    await _loadAndPlayCurrent();
  }

  // Load and play the current song
  Future<void> _loadAndPlayCurrent() async {
    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      final song = _currentQueue[_currentIndex];
      if (song.mp3Url != null) {
        await _audioPlayer.setUrl(song.mp3Url!);
        await _audioPlayer.play();
      }
    }
  }

  // Play or pause the current song
  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  // Skip to next song
  Future<void> next() async {
    if (_currentQueue.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _currentQueue.length;
    await _loadAndPlayCurrent();
  }

  // Go to previous song
  Future<void> previous() async {
    if (_currentQueue.isEmpty) return;

    _currentIndex =
        (_currentIndex - 1) < 0 ? _currentQueue.length - 1 : _currentIndex - 1;
    await _loadAndPlayCurrent();
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Clean up resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class SongListScreen extends StatefulWidget {
  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with WidgetsBindingObserver {
  late Future<List<Song>> _songs;
  final TextEditingController _searchController = TextEditingController();
  final PlaylistManager _playlistManager = PlaylistManager();
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();
  bool _isLoading = false;
  bool _showMiniPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.text = 'Believer'; // Default query
    _songs = fetchSongs('Believer');
    _loadPlaylist();

    // Listen to player state changes to update UI
    _audioPlayerManager.audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _showMiniPlayer = state.processingState != ProcessingState.idle;
      });
    });
  }

  Future<void> _loadPlaylist() async {
    await _playlistManager.loadPlaylist();
    setState(() {});
  }

  Future<List<Song>> fetchSongs(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://jiosaavn-api-pearl.vercel.app/api/search/songs?query=$query'));

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Parse the response according to the actual structure
        Map<String, dynamic> responseData = json.decode(response.body);

        // Check if success is true
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the results array from the data object
          List<dynamic> songsData = responseData['data']['results'] ?? [];
          return songsData.map((item) => Song.fromJson(item)).toList();
        } else {
          throw Exception('API returned an error format');
        }
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Error fetching songs: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is in background, pause music
      _audioPlayerManager.audioPlayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Search'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(
                    audioPlayerManager: _audioPlayerManager,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search songs',
                hintText: 'Enter song name',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: _searchController.text.isEmpty
                      ? null
                      : () {
                          _searchController.clear();
                        },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _songs = fetchSongs(value);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Song>>(
                    future: _songs,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _songs =
                                          fetchSongs(_searchController.text);
                                    });
                                  },
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.music_off,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No songs found for "${_searchController.text}"',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      } else {
                        List<Song> songs = snapshot.data!;
                        return ListView.builder(
                          itemCount: songs.length,
                          padding: EdgeInsets.only(
                            bottom: _showMiniPlayer ? 80 : 16,
                          ),
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            final bool isInPlaylist =
                                _playlistManager.isSongInPlaylist(song.id);

                            return SongTile(
                              song: song,
                              isInPlaylist: isInPlaylist,
                              onPlayPressed: () {
                                _audioPlayerManager.playSong(song);
                                setState(() {
                                  _showMiniPlayer = true;
                                });
                              },
                              onPlaylistToggle: () async {
                                if (isInPlaylist) {
                                  await _playlistManager.removeSong(song.id);
                                } else {
                                  await _playlistManager.addSong(song);
                                }
                                setState(() {});
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
          if (_showMiniPlayer)
            MiniPlayer(audioPlayerManager: _audioPlayerManager),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class SongTile extends StatelessWidget {
  final Song song;
  final bool isInPlaylist;
  final VoidCallback onPlayPressed;
  final VoidCallback onPlaylistToggle;

  const SongTile({
    Key? key,
    required this.song,
    required this.isInPlaylist,
    required this.onPlayPressed,
    required this.onPlaylistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPlayPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.thumbnailUrl != null
                    ? Image.network(
                        song.thumbnailUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, _) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.music_note,
                              color: Colors.grey.shade700),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child:
                            Icon(Icons.music_note, color: Colors.grey.shade700),
                      ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      song.artistNames,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${song.year} • ${song.formattedDuration}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Spacer(),
                        if (song.language != "Unknown")
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              song.language,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isInPlaylist ? Icons.playlist_add_check : Icons.playlist_add,
                  color: isInPlaylist ? Colors.green : Colors.grey,
                ),
                onPressed: onPlaylistToggle,
              ),
              IconButton(
                icon: Icon(Icons.play_circle_outline, color: Colors.blue),
                onPressed: onPlayPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistScreen extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const PlaylistScreen({Key? key, required this.audioPlayerManager})
      : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistManager _playlistManager = PlaylistManager();
  bool _showMiniPlayer = false;

  @override
  void initState() {
    super.initState();
    // Listen to player state changes to update UI
    widget.audioPlayerManager.audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _showMiniPlayer = state.processingState != ProcessingState.idle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Playlist'),
        actions: [
          if (_playlistManager.playlist.isNotEmpty)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                widget.audioPlayerManager.playQueue(
                  _playlistManager.playlist,
                  0,
                );
                setState(() {
                  _showMiniPlayer = true;
                });
              },
            ),
          if (_playlistManager.playlist.isNotEmpty)
            IconButton(
              icon: Icon(Icons.playlist_remove),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Playlist'),
                    content:
                        Text('Are you sure you want to clear your playlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _playlistManager.clearPlaylist();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _playlistManager.playlist.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.playlist_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Your playlist is empty',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add songs from the search screen',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: EdgeInsets.only(
                      bottom: _showMiniPlayer ? 80 : 16,
                    ),
                    itemCount: _playlistManager.playlist.length,
                    onReorder: (oldIndex, newIndex) async {
                      // Handle reordering
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Song item =
                          _playlistManager.playlist.removeAt(oldIndex);
                      _playlistManager.playlist.insert(newIndex, item);
                      await _playlistManager.savePlaylist();
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final song = _playlistManager.playlist[index];
                      return Dismissible(
                        key: Key(song.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await _playlistManager.removeSong(song.id);
                          setState(() {});
                        },
                        child: PlaylistSongTile(
                          song: song,
                          onPlayPressed: () {
                            widget.audioPlayerManager.playQueue(
                              _playlistManager.playlist,
                              index,
                            );
                            setState(() {
                              _showMiniPlayer = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (_showMiniPlayer)
            MiniPlayer(audioPlayerManager: widget.audioPlayerManager),
        ],
      ),
    );
  }
}

class PlaylistSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onPlayPressed;

  const PlaylistSongTile({
    Key? key,
    required this.song,
    required this.onPlayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPlayPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.thumbnailUrl != null
                    ? Image.network(
                        song.thumbnailUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, _) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.music_note,
                              color: Colors.grey.shade700),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child:
                            Icon(Icons.music_note, color: Colors.grey.shade700),
                      ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      song.artistNames,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${song.year} • ${song.formattedDuration}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                index:
                    0, // This is a dummy value, the actual index is provided by ReorderableListView
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
              IconButton(
                icon: Icon(Icons.play_circle_outline, color: Colors.blue),
                onPressed: onPlayPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const MiniPlayer({Key? key, required this.audioPlayerManager})
      : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final song = widget.audioPlayerManager.currentSong;
    if (song == null) return SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPlayerScreen(
              audioPlayerManager: widget.audioPlayerManager,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        height: 72,
        child: Column(
          children: [
            // Progress bar
            StreamBuilder<Duration>(
              stream: widget.audioPlayerManager.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration =
                    widget.audioPlayerManager.audioPlayer.duration ??
                        Duration.zero;
                return LinearProgressIndicator(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 2,
                );
              },
            ),
            // Player controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: song.thumbnailUrl != null
                            ? DecorationImage(
                                image: NetworkImage(song.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: song.thumbnailUrl != null
                            ? null
                            : Colors.grey.shade300,
                      ),
                      child: song.thumbnailUrl != null
                          ? null
                          : Icon(Icons.music_note, color: Colors.grey.shade700),
                    ),
                    SizedBox(width: 12),
                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            song.artistNames,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Control buttons
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: widget.audioPlayerManager.previous,
                      iconSize: 28,
                      splashRadius: 24,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: widget
                          .audioPlayerManager.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing ?? false;

                        return IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          onPressed: widget.audioPlayerManager.playPause,
                          iconSize: 36,
                          splashRadius: 24,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: widget.audioPlayerManager.next,
                      iconSize: 28,
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullPlayerScreen extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const FullPlayerScreen({Key? key, required this.audioPlayerManager})
      : super(key: key);

  @override
  _FullPlayerScreenState createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> {
  double _sliderValue = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final song = widget.audioPlayerManager.currentSong;
    if (song == null) {
      // If there's no current song, go back
      Future.microtask(() => Navigator.pop(context));
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Album art
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 8),
                            blurRadius: 16,
                          ),
                        ],
                        image: song.thumbnailUrl != null
                            ? DecorationImage(
                                image: NetworkImage(song.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: song.thumbnailUrl != null
                            ? null
                            : Colors.grey.shade300,
                      ),
                      child: song.thumbnailUrl != null
                          ? null
                          : Icon(Icons.music_note,
                              color: Colors.grey.shade700, size: 64),
                    ),
                  ),
                ),
              ),
              // Song info
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        song.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        song.artistNames,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Progress bar
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      StreamBuilder<Duration>(
                        stream: widget
                            .audioPlayerManager.audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration =
                              widget.audioPlayerManager.audioPlayer.duration ??
                                  Duration.zero;

                          // Update slider value if not dragging
                          if (!_isDragging && duration.inMilliseconds > 0) {
                            _sliderValue = position.inMilliseconds /
                                duration.inMilliseconds;
                          }

                          return Column(
                            children: [
                              Slider(
                                value: _sliderValue.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  setState(() {
                                    _sliderValue = value;
                                    _isDragging = true;
                                  });
                                },
                                onChangeEnd: (value) {
                                  final newPosition = Duration(
                                    milliseconds:
                                        (value * duration.inMilliseconds)
                                            .round(),
                                  );
                                  widget.audioPlayerManager.seek(newPosition);
                                  setState(() {
                                    _isDragging = false;
                                  });
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Controls
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle,
                          color: Colors.white.withOpacity(0.7)),
                      onPressed: () {
                        // Shuffle functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Shuffle not implemented yet')),
                        );
                      },
                      iconSize: 32,
                      splashRadius: 24,
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: widget.audioPlayerManager.previous,
                      iconSize: 40,
                      splashRadius: 28,
                    ),
                    SizedBox(width: 16),
                    StreamBuilder<PlayerState>(
                      stream: widget
                          .audioPlayerManager.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing ?? false;

                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.blue.shade700,
                            ),
                            onPressed: widget.audioPlayerManager.playPause,
                            iconSize: 40,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      onPressed: widget.audioPlayerManager.next,
                      iconSize: 40,
                      splashRadius: 28,
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.repeat,
                          color: Colors.white.withOpacity(0.7)),
                      onPressed: () {
                        // Repeat functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Repeat not implemented yet')),
                        );
                      },
                      iconSize: 32,
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
              // Volume control
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(Icons.volume_down,
                          color: Colors.white.withOpacity(0.7)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: StreamBuilder<double>(
                            stream: widget
                                .audioPlayerManager.audioPlayer.volumeStream,
                            builder: (context, snapshot) {
                              final volume = snapshot.data ?? 1.0;
                              return Slider(
                                value: volume,
                                onChanged: (value) {
                                  widget.audioPlayerManager.setVolume(value);
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              );
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.volume_up,
                          color: Colors.white.withOpacity(0.7)),
                    ],
                  ),
                ),
              ),
              // Bottom padding to account for system navigation bar
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
