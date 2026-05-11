// キャッチゲーム用プレイヤークラス
class Player extends BaseClass {

  float moveSpeed;
  int moveFrame = 0;
  float baseY;
  float baseWidth;       // 成長の基準となる元の横幅
int growthStage = 1;   // 今の段階（2倍, 4倍...）

  PImage imgNormal;
  PImage imgJump;
  PImage imgLand;
  
  color currentColor;           // 現在の色
  int colorChangeInterval = 300; // 色が変わる間隔（フレーム数で管理）
int colorChangeTimer = 0;      // タイマー（drawで加算）


//コンストラクタ
  Player(float x, float y, float w, float h, PImage imgNormal, PImage imgJump, PImage imgLand) {
    super(x, y, w, h, imgNormal);
    this.imgNormal = imgNormal;
    this.imgJump = imgJump;
    this.imgLand = imgLand;
    this.moveSpeed = 5.0;
    this.baseY = y;
    this.baseWidth = w;
  }
  
  //スライムの成長
  void grow(float amount) {
  this.w += amount;
  this.h += amount * 0.75;  // 比率を調整（縦が少し控えめ）
  
  //ボーナスポイント加算
  float currentMultiplier = this.w / baseWidth;
  if (currentMultiplier >= growthStage * 2) {
    score += 100 * growthStage;  // ボーナス加算
    println("LEVEL UP! Bonus " + (100 * growthStage));
    
    // --- ボーナススコア表示用変数にメッセージをセット ---
    levelUpMessage = "LEVEL UP! Bonus +"+ (100 * growthStage);
    levelUpMessageTimer = 60;  // 1秒表示（1フレーム = 約1/60秒）
    levelUpMessageType = "levelup";
    growthStage++;  // 次の段階へ
  }
  }
  
//スライムのサイズリセット
void resetSize() {
  this.w = baseWidth;
  this.h = baseWidth * 0.75; // 縦は元サイズに比例
  growthStage = 1;
  println("サイズリセット");
  
   // --- リセットメッセージ表示 ---
  levelUpMessage = "Too bad... Size Reset...";
  levelUpMessageTimer = 60;  // 1秒表示
  levelUpMessageType = "reset";
}

  void handleInput() {
    if (isLeftKeyPressed || isRightKeyPressed) {
      moveFrame++;
     

      // --- アニメーション画像切り替え ---
      if (moveFrame < 5) {
        this.img = imgLand;
      } else if (moveFrame < 15) {
        this.img = imgJump;
      } else {
        moveFrame = 0;
        this.img = imgNormal;
      }


      //左右移動
      if (isLeftKeyPressed) {
        this.vx = -moveSpeed;
      } else if (isRightKeyPressed) {
        this.vx = moveSpeed;
      }

      // --- スライムの動き ---
      if (moveFrame < 5) {
        this.y = baseY + 5;  // 着地で少し潰れる
      } else if (moveFrame < 10) {
        this.y = baseY - 30; // 空中に飛ぶ
      } else if (moveFrame < 15) {
        this.y = baseY;      // 通常の高さに戻る
      }
    } else {
      this.vx = 0;
      this.img = imgNormal;
      moveFrame = 0;
      this.y = baseY; // 静止時は元の位置に戻す
    }
  }

  void update() {
    handleInput();
    super.update();
    
    this.x = constrain(this.x, playAreaLeft, playAreaRight - this.w);
    this.baseY = playAreaBottom - this.h;
this.y = baseY;
    
  }


  void draw() {
    super.draw();
        
  }
}
