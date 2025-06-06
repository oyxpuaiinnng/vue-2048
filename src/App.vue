<template>
    <div class="app-container">
      <h1>学习强国</h1>
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
    // 初始化4x4棋盘，填充0
    board.value = Array(4).fill(null).map(() => Array(4).fill(0));
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
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (board.value[i][j] === 0) {
          empty.push({i, j});
        }
      }
    }
    if (empty.length > 0) {
      const idx = Math.floor(Math.random() * empty.length);
      const { i, j } = empty[idx];
      board.value[i][j] = Math.random() < 0.5 ? 2 : 4;
    }
  }
  
  // 检测游戏是否结束（没有空位且无可合并）
  function checkGameOver() {
    // 有空格，不结束
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (board.value[i][j] === 0) {
          return false;
        }
      }
    }
    // 无空格，再检测可合并
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 3; j++) {
        if (board.value[i][j] === board.value[i][j+1]) {
          return false;
        }
      }
    }
    for (let j = 0; j < 4; j++) {
      for (let i = 0; i < 3; i++) {
        if (board.value[i][j] === board.value[i+1][j]) {
          return false;
        }
      }
    }
    return true;
  }
  
  // 合并一行向左，并返回该行变动后的结果和增加的分数
  function mergeRowLeft(row) {
    const newRow = row.filter(v => v !== 0);
    let gained = 0;
    const result = [];
    for (let i = 0; i < newRow.length; i++) {
      if (i < newRow.length - 1 && newRow[i] === newRow[i+1]) {
        result.push(newRow[i] * 2);
        gained += newRow[i] * 2;
        i++;
      } else {
        result.push(newRow[i]);
      }
    }
    while (result.length < 4) {
      result.push(0);
    }
    return { row: result, gained };
  }
  
  // 执行一次移动操作
  function move(direction) {
    if (gameOver.value) return;
    let moved = false;
    let totalGained = 0;
    const b = JSON.parse(JSON.stringify(board.value)); // 备份
  
    if (direction === 'left') {
      for (let i = 0; i < 4; i++) {
        const { row, gained } = mergeRowLeft(board.value[i]);
        board.value[i] = row;
        if (gained) totalGained += gained;
        // 判断是否移动
        for (let j = 0; j < 4; j++) {
          if (row[j] !== b[i][j]) {
            moved = true;
          }
        }
      }
    }
    if (direction === 'right') {
      for (let i = 0; i < 4; i++) {
        const reversed = board.value[i].slice().reverse();
        const { row, gained } = mergeRowLeft(reversed);
        const newRow = row.reverse();
        board.value[i] = newRow;
        if (gained) totalGained += gained;
        for (let j = 0; j < 4; j++) {
          if (newRow[j] !== b[i][j]) {
            moved = true;
          }
        }
      }
    }
    if (direction === 'up') {
      for (let j = 0; j < 4; j++) {
        const col = [board.value[0][j], board.value[1][j], board.value[2][j], board.value[3][j]];
        const { row, gained } = mergeRowLeft(col);
        if (gained) totalGained += gained;
        for (let i = 0; i < 4; i++) {
          if (board.value[i][j] !== row[i]) {
            moved = true;
          }
          board.value[i][j] = row[i];
        }
      }
    }
    if (direction === 'down') {
      for (let j = 0; j < 4; j++) {
        const col = [board.value[0][j], board.value[1][j], board.value[2][j], board.value[3][j]].reverse();
        const { row, gained } = mergeRowLeft(col);
        const newCol = row.reverse();
        if (gained) totalGained += gained;
        for (let i = 0; i < 4; i++) {
          if (board.value[i][j] !== newCol[i]) {
            moved = true;
          }
          board.value[i][j] = newCol[i];
        }
      }
    }
  
    if (moved) {
      score.value += totalGained;
      // 更新最高分
      if (score.value > highScore.value) {
        highScore.value = score.value;
        localStorage.setItem('2048-highScore', highScore.value);
      }
      // 放置新块
      placeRandom();
      // 检查游戏是否结束
      if (checkGameOver()) {
        gameOver.value = true;
      }
    }
  }
  
  // 键盘事件处理（WASD 控制）
  function handleKeydown(e) {
    switch (e.key) {
      case 'w':
      case 'W':
        move('up');
        break;
      case 's':
      case 'S':
        move('down');
        break;
      case 'a':
      case 'A':
        move('left');
        break;
      case 'd':
      case 'D':
        move('right');
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
  h1 {
    font-size: 2rem;
    margin: 1rem 0;
  }
  .game-over {
    font-size: 2rem;
    color: red;
    margin-top: 10px;
  }
  </style>
  