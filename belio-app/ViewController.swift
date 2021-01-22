//
//  ViewController.swift
//  belio-app
//
//  Created by Alberto González Hernández on 13/01/21.
//

import UIKit

var musicLibraryList: [MusicTrack] = []

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var musicTable: UITableView!
    @IBOutlet var songCountLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
        
    private static let SUPPORTED_FILE_EXTENSIONS = ["mp3", "ac3", "wav", ".au", "acc", "iff", "m4a"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadMusicFromFiles()
        musicTable.register(TrackTableViewCell.nib(), forCellReuseIdentifier: TrackTableViewCell.identifier)
        musicTable.delegate = self
        musicTable.dataSource = self
        initUiElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Table view functionality
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicLibraryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let musicTrackCell = musicTable.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier, for: indexPath) as! TrackTableViewCell
        musicTrackCell.setTrackData(trackTitle: musicLibraryList[indexPath.row].title, trackArtist: musicLibraryList[indexPath.row].artist, trackArtwork: musicLibraryList[indexPath.row].artwork!)
        return musicTrackCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTrackDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination.view != nil {
            var pos = -1
            switch segue.identifier {
                case "showTrackDetail":
                    pos = musicTable.indexPathForSelectedRow!.row
                    musicTable.deselectRow(at: musicTable.indexPathForSelectedRow!, animated: true)
                case "reproduceFromStartSegue":
                    pos = 0
                case "reproduceShuffleSegue":
                    pos = Int.random(in: 0..<musicLibraryList.count)
                default:
                    pos = 0
            }
            
            let musicPlayerViewCtrl = segue.destination as! MusicPlayerViewController
            musicPlayerViewCtrl.currentTrack = musicLibraryList[pos]
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return (musicLibraryList.count > 0)
    }
    
    private func initUiElements() {
        songCountLabel.text =  "\(musicLibraryList.count) songs"
        playButton.layer.cornerRadius = 5.0
        playButton.titleEdgeInsets.left = 10
        playButton.imageEdgeInsets.left = -10
        playButton.contentEdgeInsets.top = 5
        playButton.contentEdgeInsets.bottom = 5
    
        shuffleButton.layer.cornerRadius = 5.0
        shuffleButton.titleEdgeInsets.left = 10
        shuffleButton.imageEdgeInsets.left = -10
        shuffleButton.contentEdgeInsets.top = 5
        shuffleButton.contentEdgeInsets.bottom = 5
    }

    // Music load functionality
    private func loadMusicFromFiles() {
        let fileManager = FileManager.default
        // This is th document path, you should store your mp3 files with the complete metadata here
        let documentsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("The documents path is: \(documentsPath.path) \n")
                
        do {
            let documentsFiles = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            let musicFiles = documentsFiles.filter { ViewController.SUPPORTED_FILE_EXTENSIONS.contains(String($0.suffix(3))) }
            if musicFiles.count > 0 {
                let musicFilesManager = MusicFilesManager()
                musicLibraryList = musicFilesManager.composeMusicLibraryList(fileTracks: musicFiles, documentsPath: documentsPath)
            } else {
                print("There are no music files at the moment")
                let alert = UIAlertController(title: "No music found", message: "Please add some music with the supported formats (mp3, ac3, wav, au, acc, aiff or m4a) and restart the app",
                preferredStyle: .alert)
                present(alert, animated: true)
            }
        } catch {
            print("Error while enumerating files")
        }
    }
}

