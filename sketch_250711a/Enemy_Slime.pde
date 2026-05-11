// キャッチゲーム用アイテムクラス

PImage slimeGreen;
PImage slimePink;
PImage slimeOrange;
PImage slimeWhite;

class Item extends BaseClass {

  String itemType;
  int value;
  boolean isCollected;


  Item(float x, float y, float w, float h, String type, PImage img) {
    super(x, y, w, h, img);
    this.itemType = type;
    this.isCollected = false;

    // スライムに応じた点数設定
    if (type.equals("green")) {
      this.value = 30;
    } else if (type.equals("pink")) {
      this.value = 50;
    } else if(type.equals("orange")) {
      this.value = 70;
    }else if (type.equals("white")) {
    this.value = 0;                              
  }

    // 下向きに落下
    this.vy = 3.0;
  }
  

  void update() {
    super.update();
    
     // 時間によってスピードを変える
  float speedMultiplier = 1.0;

  if (timeLeft <= 10 * 60) {
    speedMultiplier = 2.0;  // 残り10秒以下
  } else if (timeLeft <= 20 * 60) {
    speedMultiplier = 1.5;  // 残り20秒以下
  } else if (timeLeft <= 40 * 60) {
    speedMultiplier = 1.2;  // 残り40秒以下
  }

  this.y += this.vy * speedMultiplier;

    // 画面外に出たら削除
    if (this.y > height + 50) {
      this.isCollected = true;
    }
  }

  void collect() {
    this.isCollected = true;
  }

  void draw() {
    if (!isCollected) {
      super.draw();
    }
  }
}
