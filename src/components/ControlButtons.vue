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
  }
  .btn {
    background: #ffbe76;
    border: none;
    padding: 8px 12px;
    margin-right: 5px;
    border-radius: 5px;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
  }
  .btn:hover {
    background: #ff9f43;
  }
  .input {
    margin-top: 5px;
    width: 100%;
    padding: 5px;
    box-sizing: border-box;
    border: 1px solid #ccc;
    border-radius: 5px;
  }
  </style>
  