<template>
    <div class="score-board">
      <div class="score-item">
        <div>当前分数</div>
        <div class="score-value">{{ score }}</div>
      </div>
      <div class="score-item">
        <div>最高分</div>
        <div class="score-value">{{ highScore }}</div>
      </div>
    </div>
  </template>
  
  <script setup>
  const props = defineProps({
    score: Number,
    highScore: Number
  });
  </script>
  
  <style scoped>
  .score-board {
    display: flex;
    justify-content: space-around;
    margin: 10px 0;
  }
  .score-item {
    background: #fde3a7;
    border-radius: 10px;
    padding: 10px 20px;
    font-weight: bold;
  }
  .score-value {
    font-size: 1.5rem;
    color: #333;
  }
  </style>
  