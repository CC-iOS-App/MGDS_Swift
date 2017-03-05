//
//  MGMusicPlayViewController.swift
//  MGDS_Swift
//
//  Created by i-Techsys.com on 17/3/2.
//  Copyright © 2017年 i-Techsys. All rights reserved.
//

import UIKit
import AVKit

//enum MGPlayMode: Int {
//    case cicyleMode = 0,
//    randomMode,
//    singleModel
//}

//myContext的作用，主要是区分监听对象，具体作用，科自己上网查阅资料
private var currentMusicContext = 0

class MGMusicPlayViewController: UIViewController {
    // MARK: - 脱线属性
    /** 背景图片的 imageView */
    @IBOutlet weak var backgroudImageView: UIImageView!
    
    // #pragma mark --- 顶部属性 -------
    /** 歌曲名称 */
    @IBOutlet weak var songNameLabel: UILabel!
    /** 歌手 */
    @IBOutlet weak var singerLabel: UILabel!
    
    
    // #pragma mark --- 中部属性 -------
    /** 歌词 */
    @IBOutlet weak var lrcLabel: MGLrcLabel!
    /** 歌词crollView滚动条 */
    @IBOutlet weak var lrcScrollView: UIScrollView!
    /** 歌手专辑图片 */
    @IBOutlet weak var singerImageV: UIImageView!

    // #pragma mark --- 底部属性 -------
    /** 当前播放时间 */
    @IBOutlet weak var currentTimeLabel: UILabel!
    /** 歌曲总时长 */
    @IBOutlet weak var totalTimeLabel: UILabel!
    /** 按钮 */
    @IBOutlet weak var playOrStopBtn: UIButton!
    /** 滚动条 */
    @IBOutlet weak var progressSlide: UISlider!
    @IBOutlet weak var orderBtn: MGOrderButton!
    
    // MARK: - 自定义属性
    fileprivate lazy var lrcTVC: MGLrcTableViewController = MGLrcTableViewController()
    lazy var musicArr = [SongDetail]()
    dynamic var currentMusic: MGMusicModel?
    var playingIndex: Int = 0
    var playingItem: AVPlayerItem?
//    var playMode: MGPlayMode = MGPlayMode.cicyleMode
    var lrcTimer: CADisplayLink?  // 歌词的定时器
    var progressTimer: Timer?   // 进度条的定时器
    static let _indicator = MGMusicIndicator.share
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lrcScrollView.delegate = self
        setUpInit()
        setUpKVO()
    }
    
    func setSongIdArray(musicArr: [SongDetail],currentIndex: NSInteger) {
        self.musicArr = musicArr
        self.playingIndex = currentIndex
        loadSongDetail()
        
        if ((self.view != nil)) {
            
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // MARK: -  ⚠️ 必须加上这句代码 要不然获取的bounce不准确是（0，0，1000，1000）
        view.layoutIfNeeded() // 设置lrcView的滚动区域
        self.lrcScrollView.contentSize = CGSize(width: backgroudImageView.mg_width * 2, height: 0)
        self.lrcTVC.tableView.frame = self.lrcScrollView.bounds
        self.lrcTVC.tableView.mg_x = self.backgroudImageView.mg_width
        
        self.singerImageV.layer.cornerRadius = self.singerImageV.mg_width*0.5;
        self.singerImageV.clipsToBounds = true
        self.singerImageV.layer.borderWidth = 6
        self.singerImageV.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    fileprivate func loadSongDetail() {
        let parameters: [String: Any] = ["songIds": self.musicArr[playingIndex].song_id]
        NetWorkTools.requestData(type: .get, urlString: "http://ting.baidu.com/data/music/links", parameters: parameters, succeed: { (result, err) in
            guard let resultDict = result as? [String : Any] else { return }
            
            // 2.根据data该key,获取数组
            guard let resultDictArray = resultDict["data"] as? [String : Any] else { return }
            guard let dataArray = resultDictArray["songList"] as? [[String : Any]] else { return }
            self.currentMusic = MGMusicModel(dict: dataArray.first!)
            self.setUpOnce()
        }) { (err) in
            self.showHint(hint: "播放失败")
        }
    }
    deinit {
        self.removeObserver(self, forKeyPath: "currentMusic")
        playingItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playingItem?.removeObserver(self, forKeyPath: "status")
    }

}

// MARK: - KVO
extension MGMusicPlayViewController {
    fileprivate func setUpKVO() {
        self.addObserver(self, forKeyPath: "currentMusic", options: [.new,.old], context: &currentMusicContext)
        // 监听缓冲进度改变
        playingItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        // 监听状态改变
        playingItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        // 将视频资源赋值给视频播放对象
//        MGMusicPlayViewController._indicator.addObserver(self, forKeyPath: "state", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &currentMusicContext {
            let new: MGMusicModel = change![NSKeyValueChangeKey.newKey] as! MGMusicModel
            self.playingItem = MGPlayMusicTool.playMusicWithLink(link: new.songLink)
            MGNotificationCenter.addObserver(self, selector: #selector(MGMusicPlayViewController.playItemAction(item:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playingItem)
        }
        
        if keyPath == "loadedTimeRanges"{
            // 缓冲进度 暂时不处理
        }else if keyPath == "status"{
            // 监听状态改变
            if playingItem?.status == AVPlayerItemStatus.readyToPlay{
                // 只有在这个状态下才能播放
                self.playingItem = MGPlayMusicTool.playMusicWithLink(link: currentMusic!.showLink)
                beginAnimation()
            }else if playingItem?.status == .unknown{
                pauseAnimation()
            }else {
                self.showHint(hint: "加载异常")
            }
        }
    }
    // 播放音乐 - musicEnd
    @objc fileprivate func playItemAction(item: AVPlayerItem) {
        nextMusicBtnBlick()
    }
    
    func refreshIndicatorViewState() {
        
    }
}

// MARK: - Navigation
extension MGMusicPlayViewController {
    /**
     *  控制器的初始化方法(加一些视图控件, 或者, 一次性的设置)
     */
    fileprivate func setUpInit() {
        self.addChildViewController(lrcTVC)
        
        // 设置slide滚动条的滑动按钮图片
        progressSlide.setThumbImage(#imageLiteral(resourceName: "player_slider_playback_thumb"), for: .normal)
        // 在lrcView添加一个tableView
        self.lrcScrollView.addSubview(self.lrcTVC.tableView)
        // 设置分页（已在story隐藏水平滚动条）
        self.lrcScrollView.isPagingEnabled = true
    }
    
    // 设置一次的操作在这里
    func setUpOnce() {
        self.playOrStopBtn.isSelected = true
        self.songNameLabel.text = currentMusic?.songName
        self.singerLabel.text = currentMusic!.artistName + "  " + currentMusic!.albumName
        self.singerImageV.setImageWithURLString(currentMusic?.songPicBig!, placeholder: #imageLiteral(resourceName: "dzq"))
        
        // 设置背景图片  // 添加专辑图片动画
        self.backgroudImageView.setImageWithURLString(currentMusic?.songPicBig!, placeholder: #imageLiteral(resourceName: "dzq"))
        beginAnimation()
        
        self.playingItem = MGPlayMusicTool.playMusicWithLink(link: currentMusic!.songLink)
        MGNotificationCenter.addObserver(self, selector: #selector(MGMusicPlayViewController.playItemAction(item:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playingItem)
        /**
         *  加载歌曲对应的歌词资源
         */
        MGLrcLoadTool.getNetLrcModelsWithUrl(urlStr: currentMusic!.lrcLink!) { (lrcMs) in
            // 歌词界面加载数据 (lrcArray是歌词数组)
            self.lrcTVC.lrcMs = lrcMs
            self.addProgressTimer()
            self.addLrcTimer()
        }
        self.playOrStopBtn.isSelected = false
    }
    
    fileprivate func beginAnimation() {
        singerImageV.layer.removeAnimation(forKey: "rotation")
        
        /// 1.旋转动画
        let baseAnimation1 = CABasicAnimation(keyPath: "transform.rotation.z")
        baseAnimation1.fromValue = 0
        baseAnimation1.toValue = (M_PI*2)
        
        /// 2.缩放动画
        let baseAnimition2 = CABasicAnimation(keyPath: "transform.scale")
        baseAnimition2.fromValue = 1.2
        baseAnimition2.toValue = 0.8
        
        /// 3.动画组
        let groupAnimition = CAAnimationGroup()
        groupAnimition.animations = [baseAnimation1,baseAnimition2]
        groupAnimition.duration = 20;
        groupAnimition.repeatCount = MAXFLOAT;
        groupAnimition.fillMode = kCAFillModeForwards; // 保存动画最前面的效果.
//        groupAnimition.autoreverses = true // 设置动画自动反转(怎么去, 怎么回)
        
        // 添加动画组
        self.singerImageV.layer.add(groupAnimition, forKey: "rotation")
    }
    
    // 暂停动画
     fileprivate func pauseAnimation() {
        self.singerImageV.layer.pauseAnimate()
    }
    
    // 继续动画
    fileprivate func resumeAnimation() {
        self.singerImageV.layer.resumeAnimate()
    }
}


// MARK: - Action
extension MGMusicPlayViewController {
    // 上一首
    @IBAction func preMusicBtnBlick() {
        changeMusic(variable: -1)
        setUpOnce()
    }
    // 播放OR暂停
    @IBAction func playOrStopBtnClick() {
        playOrStopBtn.isSelected = !playOrStopBtn.isSelected;
        if (playOrStopBtn.isSelected) {
            MGPlayMusicTool.pauseMusicWithLink(link: currentMusic!.songLink)
            pauseAnimation()
        }else{
            resumeAnimation()
           self.playingItem = MGPlayMusicTool.playMusicWithLink(link: currentMusic!.songLink)
        }
    }
    // 下一首
    @IBAction func nextMusicBtnBlick() {
        changeMusic(variable: 1)
        setUpOnce()
    }
    // 根据模式播放音乐🎵
    fileprivate func changeMusic(variable: NSInteger) {
        removeProgressTimer(); removeLrcTimer()
        MGPlayMusicTool.stopMusicWithLink(link: currentMusic!.songLink)
        switch(orderBtn.orderIndex){
            case 1: //顺序播放
                cicyleMusic(variable: variable)
            case 2: //随机播放
                randomMusic()
            case 3: //单曲循环
                break
            default:
                break
        }
//        switch (self.playMode) {
//            case .cicyleMode:
//                cicyleMusic(variable: variable)
//            case .randomMode:
//                randomMusic()
//            case .singleModel:
//                break
//        }
        loadSongDetail()
        addProgressTimer()
        addLrcTimer()
    }
    
    fileprivate func cicyleMusic(variable: NSInteger) {
        if (self.playingIndex == self.musicArr.count - 1) {
            self.playingIndex = 0
        } else if(self.playingIndex == 0){
            self.playingIndex = self.musicArr.count - 1
        } else{
            self.playingIndex = variable + self.playingIndex
        }
    }
    
    fileprivate func randomMusic() {
        self.playingIndex = Int(arc4random_uniform(UInt32(musicArr.count))) - 1
        //    self.playingIndex = Int(arc4random())/ self.musicArr.count
    }
    
    // 随机播放
    @IBAction func randomPlayClick(_ btn: UIButton) {
    }
    
    // 更多按钮
    @IBAction func moreBtnClick(_ btn: UIButton) {
    }
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - slide滑块相关方法
    /// （可随机拖到slide任何位置）
    @IBAction func slideValueChange(_ slider: UISlider) {
        if self.playingItem == nil {
            return
        }
        self.currentTimeLabel.text = MGTimeTool.getFormatTimeWithTimeInterval(timeInterval: Double(slider.value))
        let dragCMtime = CMTimeMake(Int64(slider.value), 1)
        MGPlayMusicTool.setUpCurrentPlayingTime(time: dragCMtime, link: currentMusic!.songLink)
    }
    
    /// 添加点按手势，随机拖拽播放
    @IBAction func seekToTimeIntValue(_ tap: UITapGestureRecognizer) { }
    // 手按下去的时候，进行的一些操作
    @IBAction func touchUp(_ sender: UISlider) { }
    // 手按下去的时候，清除updateTime定时器
    @IBAction func touchDown(_ sender: UISlider) { }
}

// MARK: - 定时器相关方法
extension MGMusicPlayViewController {
    fileprivate func addProgressTimer() {
        self.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MGMusicPlayViewController.updateProgress), userInfo: nil, repeats: true)
    }
    fileprivate func addLrcTimer() {
        self.lrcTimer = CADisplayLink(target: self, selector: #selector(MGMusicPlayViewController.updateLrcLabel))
        lrcTimer?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    fileprivate func removeProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    fileprivate func removeLrcTimer() {
        lrcTimer?.invalidate()
        lrcTimer = nil
    }
    
    // 更新
    @objc fileprivate func updateProgress() {
        self.currentTimeLabel.text = MGTimeTool.getFormatTimeWithTimeInterval(timeInterval: CMTimeGetSeconds(self.playingItem!.currentTime()))
    
        self.totalTimeLabel.text = MGTimeTool.getFormatTimeWithTimeInterval(timeInterval: CMTimeGetSeconds(self.playingItem!.asset.duration))

        self.progressSlide.value = Float(CMTimeGetSeconds(self.playingItem!.currentTime()));
        // MARK: - ⚠️防止过快的切换歌曲导致duration == nan而崩溃  BUG直接使用self.playingItem!.duration返回nan导致崩溃
        if __inline_isnand(CMTimeGetSeconds(self.playingItem!.asset.duration)) == 1 {
            self.progressSlide.maximumValue = Float(CMTimeGetSeconds(self.playingItem!.currentTime())) + 1.00
        } else {
            self.progressSlide.maximumValue = Float(CMTimeGetSeconds(self.playingItem!.asset.duration))
        }
    }
    
    @objc fileprivate func updateLrcLabel() {
        // 计算当前播放时间, 对应的歌词行号
        let row = MGLrcLoadTool.getRowWithCurrentTime(currentTime: CMTimeGetSeconds((self.playingItem?.currentTime())!), lrcMs: self.lrcTVC.lrcMs)
        self.lrcTVC.scrollRow = row
        
        // 显示歌词label
        // 取出当前正在播放的歌词数据模型
        let lrcModel = self.lrcTVC.lrcMs[row];
//        let ctime = playingItem!.currentTime()
//        let currentTimeSec: Float = Float(ctime.value) /  Float(ctime.timescale)
//        let costTime = Double(currentTimeSec) - lrcModel.beginTime
        let costTime = Double(CMTimeGetSeconds(playingItem!.currentTime()))-lrcModel.beginTime
        let linetime = lrcModel.endTime - lrcModel.beginTime
        self.lrcLabel.progress = costTime/linetime
        self.lrcTVC.progress = self.lrcLabel.progress
        self.lrcLabel.text = lrcModel.lrcText;
    }
}

// MARK: - 设置锁屏信息／后台
extension MGMusicPlayViewController {
    fileprivate func setUpLockInfo() {
        //1.获取当前播放中心
        let center = MPNowPlayingInfoCenter.default()
        var infos = [String: Any]()
        
        infos[MPMediaItemPropertyTitle] = currentMusic?.songName
        infos[MPMediaItemPropertyArtist] = currentMusic?.artistName
        infos[MPMediaItemPropertyPlaybackDuration] =  self.playingItem?.duration
        infos[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playingItem?.duration
        infos[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200,height: 200), requestHandler: { (size) -> UIImage in
            return UIImage(named: self.currentMusic!.songPicBig)!
        })
        
        center.nowPlayingInfo = infos
        
        //设置远程操控
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let _ = self.becomeFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    func remoteControlReceivedWithEvent(event: UIEvent) {
        switch (event.subtype) {
            case UIEventSubtype.remoteControlPlay, .remoteControlPause:
                playOrStopBtnClick()
            case .remoteControlStop:
                MGPlayMusicTool.stopMusicWithLink(link: currentMusic!.songLink)
            case .remoteControlNextTrack:
                nextMusicBtnBlick()
            case .remoteControlPreviousTrack:
                preMusicBtnBlick()
            default:
                break;
        }
    }
}

extension MGMusicPlayViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let scale = offsetX/self.backgroudImageView.mg_width
        self.singerImageV.alpha = 1 - scale
        self.lrcLabel.alpha = 1 - scale
    }
}
