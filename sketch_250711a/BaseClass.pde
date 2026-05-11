// すべてのオブジェクトの基礎となるクラス
//位置とサイズと移動速度を持ち、画像も設定できるオブジェクト

class BaseClass {

  float x, y; //位置
  float vx, vy; //加速度
  float w, h; //サイズ
  PImage img; //画像


  //コンストラクタ（画像も設定する）
  BaseClass(float x, float y, float w, float h, PImage img) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.vx = 0;
    this.vy = 0;
    this.img = img;
  }

  void update() {
    this.x += this.vx;
    this.y += this.vy;
  }

  void draw() {
    //もし画像が設定されていれば表示する
    if (this.img != null) {
      image(this.img, this.x, this.y, this.w, this.h);
    } else {
      //画像がないときはrectを表示する
      rect(this.x, this.y, this.w, this.h);
    }
  }

  //画像を設定する
  void setImage(PImage img) {
    this.img = img;
  }

}
