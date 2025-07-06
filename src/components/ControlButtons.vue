<template>
    <div class="controls">
      <button @click="$emit('reset')" class="btn">重新开始</button>
      <button @click="$emit('save')" class="btn">保存进度</button>
      <button @click="$emit('load')" class="btn">加载进度</button>
      <input
        :value="modelValue"
        @input="updateValue"
        placeholder="粘贴 Base64 存档"
        class="input"
      />
    </div>
  </template>
  
  <script setup>
  const props = defineProps({
    modelValue: String
  });
  const emit = defineEmits(['update:modelValue', 'reset', 'save', 'load']);
  
  function updateValue(e) {
    emit('update:modelValue', e.target.value);
  }
  </script>
  
  <style scoped>
  .controls {
    margin: 10px 0;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
  }
  
  .btn {
    background: #ffbe76;
    border: none;
    padding: 8px 12px;
    border-radius: 5px;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
    flex: 1 1 auto;
    min-width: 100px;
    text-align: center;
    transition: background 0.3s ease;
  }
  
  .btn:hover {
    background: #ff9f43;
  }
  
  .input {
    flex: 1 1 100%;
    margin-top: 5px;
    padding: 5px;
    box-sizing: border-box;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 1rem;
  }
  
  /* 手机屏幕调整 */
  @media (max-width: 480px) {
    .btn {
      padding: 6px 10px;
      font-size: 0.9rem;
      min-width: 80px;
    }
  
    .input {
      font-size: 0.9rem;
    }
  }
  </style>
  