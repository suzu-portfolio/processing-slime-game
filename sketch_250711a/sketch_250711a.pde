// キャッチゲーム
// --- ゲームオブジェクト ---

//BGM
import ddf.minim.*;
Minim minim;
AudioPlayer bgm;
boolean bgmStarted = false;

Player player;
ArrayList<Item> items;
int score;
int timeLeft;
int spawnTimer;
boolean gameOver;
PImage gameFrame;

//スライムをバラバラに排出
ArrayList<SpawnTask> spawnQueue = new ArrayList<SpawnTask>();

// --- 入力状態 ---
boolean isLeftKeyPressed = false;
boolean isRightKeyPressed = false;

//スピードアップメッセージ
String speedMessage = "";
int speedMessageTimer = 0;
int currentSpeedStage = 0;  // 0 = 初期, 1 = 40秒, 2 = 20秒, 3 = 10秒

// 枠内でスライムが動ける範囲（グローバルに追加）
int playAreaLeft = 196;
int playAreaRight = 1090;
int playAreaTop = 40;
int playAreaBottom = 590;

PImage backgroundImg;

//スタート画面と結果画面
PImage startImage;
PImage resultImage1, resultImage2, resultImage3, resultImage4;
boolean showStartScreen = true;

//レベルアップメッセージ
String levelUpMessage = "";
int levelUpMessageTimer = 0;  // フレーム数で管理（例：60で約1秒）
String levelUpMessageType = "none";  // "levelup" または "reset"

// --- 初期化処理 ---
void setup() {
  size(1280, 720);
  
  // BGM 初期化
  minim = new Minim(this);
  bgm = minim.loadFile("bgm.mp3", 2048);
  
  backgroundImg = loadImage("haikei2-1.png");  // 画像読み込み

  frameRate(60);
  
  gameFrame = loadImage("game1.png");
   startImage = loadImage("game.png");
  resultImage1 = loadImage("god.png");     // score >= 1000
  resultImage2 = loadImage("king.png"); // 1000 <= score < 700
  resultImage3 = loadImage("super.png"); // 500 <= score < 500
  resultImage4 = loadImage("nomal.png"); // score < 300
  

  // 基本設定
  rectMode(CORNER);
  imageMode(CORNER);
  ellipseMode(CORNER);
  textAlign(CENTER, CENTER);

  // ゲーム初期化
  initGame();
}

// --- ゲーム初期化 ---
void initGame() {

  slimeGreen = loadImage("s-g.png");
  slimePink = loadImage("s-r.png");
  slimeOrange = loadImage("s-o.png");
  slimeWhite = loadImage("s-b.png");

  PImage imgNormal = loadImage("ps-1.png");
  PImage imgJump = loadImage("ps-2.png");
  PImage imgLand = loadImage("ps-3.png");

  player = new Player(width/2 - 40, height - 80,80, 60, imgNormal, imgJump, imgLand);
  items = new ArrayList<Item>();
  score = 0;
  timeLeft = 60 * 60; // 60秒
  spawnTimer = 0;
  gameOver = false;
  
  // --- メッセージ類の初期化 ---
  levelUpMessage = "";
  levelUpMessageTimer = 0;
  levelUpMessageType = "";

  // --- スピードアップ用の変数リセット ---
  currentSpeedStage = 0;
  speedMessage = "";
  speedMessageTimer = 0;

  
}



// --- メインループ ---
void draw() {
  //スタート画面
   if (showStartScreen) {
    image(startImage, 0, 0);
    fill(255);
    textSize(24);
    text("Press Space to Start!", width/2, 650);
    return;  // スタート画面を表示して終了
  }
  
  background(50, 100, 150);
  image(backgroundImg, 0, 0);  // 背景を画面左上に描画
  
  
// レベルアップまたはリセットメッセージの表示
if (levelUpMessageTimer > 0) {
  textSize(36);
  textAlign(CENTER, CENTER);

  if (levelUpMessageType.equals("levelup")) {
    fill(255, 255, 0); // 黄色
  } else if (levelUpMessageType.equals("reset")) {
    fill(255, 0, 0);   // 赤色
  }

  text(levelUpMessage, width / 2, height / 2 - 100);
  levelUpMessageTimer--;
}

  if (!gameOver) {
    updateGame();
  }

  drawGame();
  drawUI();
  
   // 枠を一番上に重ねて描画
  image(gameFrame, 0, 0, width, height);
  
}

// --- ゲーム更新 ---
void updateGame() {
  // プレイヤー更新
  player.update();
  

  // 1秒ごとにアイテム生成
  spawnTimer++;
  if (spawnTimer > 60) {
   int numToSchedule = int(random(2, 4));  // 毎秒3～5個予約
  for (int i = 0; i < numToSchedule; i++) {
    int delay = int(random(0, 30));  // 0〜30フレームの中でランダムに
    spawnQueue.add(new SpawnTask(delay));
  }
    spawnTimer = 0;
  }

// --- スライム落下処理 ---
for (int i = spawnQueue.size() - 1; i >= 0; i--) {
  if (spawnQueue.get(i).update()) {
    spawnItem();
    spawnQueue.remove(i);
  }
}

  // --- スピード段階チェック ---
  if (timeLeft <= 10 * 60 && currentSpeedStage < 3) {
    speedMessage = "Speed Up!";
    speedMessageTimer = 90;  // 1.5秒表示（60fps換算）
    currentSpeedStage = 3;
  } else if (timeLeft <= 20 * 60 && currentSpeedStage < 2) {
    speedMessage = "Speed Up!";
    speedMessageTimer = 90;
    currentSpeedStage = 2;
  } else if (timeLeft <= 40 * 60 && currentSpeedStage < 1) {
    speedMessage = "Speed Up!";
    speedMessageTimer = 90;
    currentSpeedStage = 1;
  }


  // アイテム更新
  for (Item item : items) {
    item.update();
  }

  // 収集判定
  for (Item item : items) {
    if (!item.isCollected && isColliding(player, item)) {
      item.collect();

//スライムサイズとペナルティ
      if (item.itemType.equals("white")) {
        // グレースライム → リセット
        player.resetSize();
         score = 0;  // スコアもペナルティ
      } else if (item.w <= player.w) {
        // 自分より小さいスライム → 吸収して大きくなる
        score += item.value;
        player.grow(item.w * 0.1);  // 成長率は調整可能
      } else {
        // 自分より大きいスライム → ミスで小さくなる
        player.resetSize();  // 縮小率も調整可能
        score = max(0, score - 80);  // スコアもペナルティ
      }
    }
    
    if (timeLeft <= 0) {
  gameOver = true;
}
    
    
  }

  // 収集されたアイテムを削除
  items.removeIf(item -> item.isCollected);

  // タイマー減少
  timeLeft--;
  if (timeLeft <= 0) {
    gameOver = true;
    
    if (bgm.isPlaying()) {
    bgm.pause();  // BGM を一時停止（完全停止したい場合は stop() にしてもOK）
  }
  }
}

// --- アイテム生成 ---
void spawnItem() {
  float size = random(30, 80);
float x = random(playAreaLeft, playAreaRight - size);  // 枠内
float y = playAreaTop - size;  // 画面上から降ってくる
  
  String[] types = {"green", "pink", "orange", "white"};
  String type = types[int(random(types.length))];

  PImage img;
  if (type.equals("green")) {
    img = slimeGreen;
  } else if (type.equals("pink")) {
    img = slimePink;
  } else if (type.equals("orange")) {
    img = slimeOrange;
  } else {
    img = slimeWhite;
  }
  
  // アイテム作成してリストに追加
items.add(new Item(x, y, size, size, type, img));
  
}

// --- 描画処理 ---
void drawGame() {
  // アイテム描画
  for (Item item : items) {
    item.draw();
  }

  // プレイヤー描画
  player.draw();
}


// --- UI描画 ---
void drawUI() {
  fill(255);
  textAlign(LEFT, TOP);
  textSize(30);
  text("Score: " + score, 280, 100);
  text("Time: " + (timeLeft / 60), 280, 150);

//プレイ中操作方法表示アナウンス
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Arrow Keys: Move", width/2, height - 65);
  text("Catch falling Slimes!", width/2, height - 50);

//結果画面のスコアによる分岐
  if (gameOver) {
    PImage resultImage;
  if (score >= 1000) {
    resultImage = resultImage1;
  } else if (score >= 700) {
    resultImage = resultImage2;
  } else if (score >= 300) {
    resultImage = resultImage3;
  } else {
    resultImage = resultImage4;
  }

  image(resultImage, 0, 0);
    
    //結果の表示
    fill(225);
    textSize(36);
    text("TIME UP!", width/2 -150, height/2 - 60);
    text("Final Score: " + score, width/2 -150, height/2 - 20);
    
    // --- ランクメッセージを表示 ---
  String rankMessage = "";
  if (score >= 1000) {
    rankMessage = "You are…GOD SLIME!!!!";
  } else if (score >= 700) {
    rankMessage = "You are…KING SLIME!!!";
  } else if (score >= 300) {
    rankMessage = "You are…SUPER SLIME!!";
  } else {
    rankMessage = "You are…NORMAL SLIME!";
  }
  textSize(42);
  text(rankMessage, width/2 -150, height/2 + 20);

  text("Press R to Restart", width/2 -150, height/2 + 80);
  }

  // --- スピードアップメッセージ ---
  if (speedMessageTimer > 0) {
    fill(0, 255, 255); // 水色（目立つ色）
    textSize(48);
    textAlign(CENTER);
    text(speedMessage, width / 2, height / 2);
    speedMessageTimer--;
  }
  
}

// --- キー入力 ---
void keyPressed() {
  
   if (showStartScreen && key == ' ') {
    showStartScreen = false;
    
    if (!bgmStarted) {
      bgm.loop();      // ループ再生
      bgmStarted = true;
    }
    
    return;
  }
  
  if (gameOver && (key == 'r' || key == 'R')) {
    initGame();
    gameOver = false;

  if (!bgm.isPlaying()) {
    bgm.rewind();  // 頭から再生する
    bgm.loop();
  }
  }

  if (keyCode == LEFT) {
    isLeftKeyPressed = true;
  } else if (keyCode == RIGHT) {
    isRightKeyPressed = true;
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    isLeftKeyPressed = false;
  } else if (keyCode == RIGHT) {
    isRightKeyPressed = false;
  }
}

void stop() {
  bgm.close();
  minim.stop();
  super.stop();
}
