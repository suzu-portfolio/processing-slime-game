//複数のスライムを予約してタイミングをずらして生成するクラス

class SpawnTask {
  int timer;
  
  SpawnTask(int delay) {
    this.timer = delay;
  }

  boolean update() {
    timer--;
    return timer <= 0;  // trueになったら落下実行
  }
}
