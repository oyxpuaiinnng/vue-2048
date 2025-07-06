<template>
    <div class="app-container" @touchstart="handleTouchStart" @touchmove.prevent @touchend="handleTouchEnd">
        <h1 class="game-title">/3/3^.^/3/3的729<br>(因为2187太难了)</h1>

        <ScoreBoard :score="score" :highScore="highScore" />
        <ControlButtons v-model="saveData" @reset="initGame" @save="saveGame" @load="loadGame" />
        <GameBoard :board="board" />
        <div v-if="gameOver" class="game-over">游戏结束！</div>
    </div>

</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import ScoreBoard from './components/ScoreBoard.vue';
import ControlButtons from './components/ControlButtons.vue';
import GameBoard from './components/GameBoard.vue';

// 游戏状态
const board = ref([]);
const score = ref(0);
const highScore = ref(0);
const gameOver = ref(false);
const saveData = ref('');  // 存储Base64的存档数据

// 初始化游戏（重置）
function initGame() {
    // 重置分数与状态
    score.value = 0;
    gameOver.value = false;
    // 初始化5x5棋盘，填充0
    board.value = Array(5).fill(null).map(() => Array(5).fill(0));
    // 随机生成两个初始数字
    placeRandom();
    placeRandom();
    // 读取并更新最高分
    const savedHigh = localStorage.getItem('2048-highScore');
    highScore.value = savedHigh ? parseInt(savedHigh) : 0;
}

// 随机在空格生成一个2或4
function placeRandom() {
  const empty = [];
  for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 5; j++) {
      if (board.value[i][j] === 0) {
        empty.push({ i, j });
      }
    }
  }
  if (empty.length > 0) {
    const idx = Math.floor(Math.random() * empty.length);
    const { i, j } = empty[idx];
    board.value[i][j] = Math.random() < 0.5 ? 3 : 9;
  }
}

// 检测游戏是否结束（没有空位且无可合并）
function canMergeTriple() {
  for (let i = 0; i < 5; i++) {
    for (let j = 0; j <= 2; j++) {
      const val = board.value[i][j];
      if (val !== 0 && val === board.value[i][j + 1] && val === board.value[i][j + 2]) return true;
    }
  }
  for (let j = 0; j < 5; j++) {
    for (let i = 0; i <= 2; i++) {
      const val = board.value[i][j];
      if (val !== 0 && val === board.value[i + 1][j] && val === board.value[i + 2][j]) return true;
    }
  }
  return false;
}

function checkGameOver() {
  for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 5; j++) {
      if (board.value[i][j] === 0) return false;
    }
  }
  return !canMergeTriple();
}

// 合并一行向左，并返回该行变动后的结果和增加的分数
function slideLeft(board) {
  let moved = false;
  let gained = 0;

  for (let i = 0; i < 5; i++) {
    const row = board[i];
    const originalRow = [...row]; // snapshot before change
    const filtered = row.filter(v => v !== 0);
    const newRow = [];

    for (let j = 0; j < filtered.length;) {
      if (
        j + 2 < filtered.length &&
        filtered[j] === filtered[j + 1] &&
        filtered[j] === filtered[j + 2]
      ) {
        const merged = filtered[j] * 3;
        newRow.push(merged);
        gained += merged;
        j += 3;
      } else {
        newRow.push(filtered[j]);
        j += 1;
      }
    }

    while (newRow.length < 5) newRow.push(0);
    board[i] = newRow;

    if (!(originalRow.length === newRow.length && originalRow.every((v, i) => v === newRow[i]))) moved = true;
  }

  return { moved, gained };
}

// 执行一次移动操作
function moveLeft() {
  const { moved, gained } = slideLeft(board.value);
  if (moved) {
    score.value += gained;
    placeRandom();
    if (checkGameOver()) gameOver.value = true;
  }
}

function moveRight() {
  reverseRows(board.value);
  const { moved, gained } = slideLeft(board.value);
  reverseRows(board.value);
  if (moved) {
    score.value += gained;
    placeRandom();
    if (checkGameOver()) gameOver.value = true;
  }
}

function moveUp() {
  transpose(board.value);
  const { moved, gained } = slideLeft(board.value);
  transpose(board.value);
  if (moved) {
    score.value += gained;
    placeRandom();
    if (checkGameOver()) gameOver.value = true;
  }
}

function moveDown() {
  transpose(board.value);
  reverseRows(board.value);
  const { moved, gained } = slideLeft(board.value);
  reverseRows(board.value);
  transpose(board.value);
  if (moved) {
    score.value += gained;
    placeRandom();
    if (checkGameOver()) gameOver.value = true;
  }
}


function transpose(matrix) {
  const n = matrix.length;
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      [matrix[i][j], matrix[j][i]] = [matrix[j][i], matrix[i][j]];
    }
  }
}

function reverseRows(matrix) {
  for (let row of matrix) {
    row.reverse();
  }
}

// 键盘事件处理（WASD 控制）
function handleKeydown(e) {
    switch (e.key) {
        case 'w':
        case 'W':
            moveUp();
            break;
        case 's':
        case 'S':
            moveDown();
            break;
        case 'a':
        case 'A':
            moveLeft();
            break;
        case 'd':
        case 'D':
            moveRight();
            break;
    }
}

// 保存进度（生成Base64字符串）
function saveGame() {
    const data = {
        board: board.value,
        score: score.value
    };
    saveData.value = btoa(JSON.stringify(data));
}

// 加载进度（从Base64字符串读取）
function loadGame() {
    if (!saveData.value) {
        return;
    }
    try {
        const data = JSON.parse(atob(saveData.value));
        if (data.board && data.score != null) {
            board.value = data.board;
            score.value = data.score;
            // 更新最高分
            if (score.value > highScore.value) {
                highScore.value = score.value;
                localStorage.setItem('2048-highScore', highScore.value);
            }
            gameOver.value = checkGameOver();
        }
    } catch (e) {
        alert('存档无效！');
    }
}

// 初始化与事件监听
// 触摸坐标 
const touchStartX = ref(0);
const touchStartY = ref(0);
const touchEndX = ref(0);
const touchEndY = ref(0);

// 记录起点
function handleTouchStart(e) {
  const t = e.changedTouches[0];
  touchStartX.value = t.clientX;
  touchStartY.value = t.clientY;
}

// 记录终点
function handleTouchEnd(e) {
  const t = e.changedTouches[0];
  touchEndX.value = t.clientX;
  touchEndY.value = t.clientY;

  const dx = touchEndX.value - touchStartX.value;
  const dy = touchEndY.value - touchStartY.value;

  // 判断滑动方向
  const threshold = 50;
  if (Math.abs(dx) > Math.abs(dy)) {
    // 横向滑动
    if (dx > threshold) {
      moveRight();
    } else if (dx < -threshold) {
      moveLeft();
    }
  } else {
    // 纵向滑动
    if (dy > threshold) {
      moveDown();
    } else if (dy < -threshold) {
      moveUp();
    }
  }
}

onMounted(() => {
    initGame();
    window.addEventListener('keydown', handleKeydown);
});
onBeforeUnmount(() => {
    window.removeEventListener('keydown', handleKeydown);
});
</script>

<style>
.app-container {
    max-width: 400px;
    margin: 0 auto;
    text-align: center;
    font-family: 'Arial', sans-serif;
}

.game-title {
    font-size: 2rem;
    margin: 1rem 0;
}
@media (max-width: 480px) {
  .game-title {
    font-size: 1.2rem;
  }
}

@media (max-width: 360px) {
  .game-title {
    font-size: 1rem;
  }
}
.game-over {
    font-size: 2rem;
    color: red;
    margin-top: 10px;
}
</style>