<template>
    <div :class="['tile', 'tile-' + value]">{{ value }}</div>
  </template>
  
  <script setup>
  const props = defineProps({
    value: Number
  });
  </script>
  
  <style scoped>
  .tile {
    width: 100%;
    height: 100%;
    border-radius: 5px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    color: #333;
  }
  .tile-2 { background: #fcefe6; }
  .tile-4 { background: #fadbd8; }
  .tile-8 { background: #f8c8a0; }
  .tile-16 { background: #f6b784; }
  .tile-32 { background: #f39c70; color: #fff; }
  .tile-64 { background: #f2784b; color: #fff; }
  .tile-128 { background: #f5da81; }
  .tile-256 { background: #f4d03f; }
  .tile-512 { background: #f1c40f; }
  .tile-1024 { background: #f39c12; }
  .tile-2048 { background: #f5b041; }
  </style>
  