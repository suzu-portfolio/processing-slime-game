// ========== 基本衝突判定 ==========

// オブジェクト同士の衝突判定
boolean isColliding(BaseClass obj1, BaseClass obj2) {
  return (obj1.x < obj2.x + obj2.w &&
          obj1.x + obj1.w > obj2.x &&
          obj1.y < obj2.y + obj2.h &&
          obj1.y + obj1.h > obj2.y);
}

// 接地判定
boolean isOnGround(BaseClass obj, ArrayList<BaseClass> platforms) {
  for (BaseClass platform : platforms) {
    if (obj.x < platform.x + platform.w &&
        obj.x + obj.w > platform.x &&
        obj.y + obj.h >= platform.y &&
        obj.y + obj.h <= platform.y + 5) {
      return true;
    }
  }
  return false;
}

// ========== 衝突解決 ==========

// 静的オブジェクトとの衝突解決
void resolveCollision(BaseClass moving, BaseClass staticObj) {
  if (!isColliding(moving, staticObj)) return;

  // 重なり量を計算
  float overlapLeft = (moving.x + moving.w) - staticObj.x;
  float overlapRight = (staticObj.x + staticObj.w) - moving.x;
  float overlapTop = (moving.y + moving.h) - staticObj.y;
  float overlapBottom = (staticObj.y + staticObj.h) - moving.y;

  // 最小重なり方向を特定
  float minOverlap = min(min(overlapLeft, overlapRight), min(overlapTop, overlapBottom));

  if (minOverlap == overlapLeft) {
    // 左側衝突
    moving.x = staticObj.x - moving.w;
    moving.vx = 0;  // 完全停止する場合
  } else if (minOverlap == overlapRight) {
    // 右側衝突
    moving.x = staticObj.x + staticObj.w;
    moving.vx = 0;  // 完全停止する場合
  } else if (minOverlap == overlapTop) {
    // 上側衝突
    moving.y = staticObj.y - moving.h;
    moving.vy = 0;  // 完全停止する場合
  } else if (minOverlap == overlapBottom) {
    // 下側衝突
    moving.y = staticObj.y + staticObj.h;
    moving.vy = 0;  // 完全停止する場合
  }
}

// 動的オブジェクト同士の衝突解決
void resolveDynamicCollision(BaseClass obj1, BaseClass obj2, float bounce) {
  if (!isColliding(obj1, obj2)) return;

  // 重なり量を計算
  float overlapX = min(obj1.x + obj1.w, obj2.x + obj2.w) - max(obj1.x, obj2.x);
  float overlapY = min(obj1.y + obj1.h, obj2.y + obj2.h) - max(obj1.y, obj2.y);

  if (overlapX < overlapY) {
    // 水平方向の衝突
    if (obj1.x < obj2.x) {
      obj1.x -= overlapX * 0.5;
      obj2.x += overlapX * 0.5;
    } else {
      obj1.x += overlapX * 0.5;
      obj2.x -= overlapX * 0.5;
    }
    // 速度交換
    float tempVx = obj1.vx;
    obj1.vx = obj2.vx * bounce;
    obj2.vx = tempVx * bounce;
  } else {
    // 垂直方向の衝突
    if (obj1.y < obj2.y) {
      obj1.y -= overlapY * 0.5;
      obj2.y += overlapY * 0.5;
    } else {
      obj1.y += overlapY * 0.5;
      obj2.y -= overlapY * 0.5;
    }
    // 速度交換
    float tempVy = obj1.vy;
    obj1.vy = obj2.vy * bounce;
    obj2.vy = tempVy * bounce;
  }
}

// ========== 物理処理 ==========

// 重力適用
void applyGravity(BaseClass obj, float gravity) {
  obj.vy += gravity;
}

// 境界チェック
void checkBounds(BaseClass obj, float minX, float minY, float maxX, float maxY, float bounce) {
  if (obj.x < minX) {
    obj.x = minX;
    obj.vx = abs(obj.vx) * bounce;
  }
  if (obj.x + obj.w > maxX) {
    obj.x = maxX - obj.w;
    obj.vx = -abs(obj.vx) * bounce;
  }
  if (obj.y < minY) {
    obj.y = minY;
    obj.vy = abs(obj.vy) * bounce;
  }
  if (obj.y + obj.h > maxY) {
    obj.y = maxY - obj.h;
    obj.vy = -abs(obj.vy) * bounce;
  }
}

// プラットフォーム群との衝突処理
void handlePlatforms(BaseClass obj, ArrayList<BaseClass> platforms) {
  for (BaseClass platform : platforms) {
    resolveCollision(obj, platform);
  }
}

// 摩擦適用
void applyFriction(BaseClass obj, float friction) {
  obj.vx *= friction;
}

// 速度制限
void limitVelocity(BaseClass obj, float maxSpeed) {
  float speed = sqrt(obj.vx * obj.vx + obj.vy * obj.vy);
  if (speed > maxSpeed) {
    obj.vx = (obj.vx / speed) * maxSpeed;
    obj.vy = (obj.vy / speed) * maxSpeed;
  }
}
