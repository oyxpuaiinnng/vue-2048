<!-- src/components/GameBoard.vue -->
<template>
    <div class="grid">
      <div v-for="(row, i) in board" :key="i" class="grid-row">
        <div v-for="(cell, j) in row" :key="j" class="grid-cell">
          <!-- 只有 cell>0 时才渲染 Tile -->
          <Tile v-if="cell > 0" :value="cell" />
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  // 导入 Tile 组件
  import Tile from './Tile.vue';
  
  const props = defineProps({
    board: Array
  });
  </script>
  
  <style scoped>
  .grid {
    display: inline-block;
    background: #bbada0;
    padding: 10px;
    border-radius: 10px;
  }
  .grid-row {
    display: flex;
  }
  .grid-cell {
    width: 70px;
    height: 70px;
    margin: 5px;
    background: #ccc0b3;
    border-radius: 5px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  </style>
  