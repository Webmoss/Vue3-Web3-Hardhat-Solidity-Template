<script setup>
// import { onMounted, ref } from 'vue';
// import AppHeader from './components/AppHeader.vue';
// import ReloadPrompt from './components/ReloadPrompt.vue';

// const currentAccount = ref();

// async function checkIfWalletIsConnected() {
//   const { ethereum } = window;

//   if (!ethereum) {
//     console.log('Error: No ethereum window object');
//     return;
//   } else {
//     console.log('we have an ethereum object', ethereum);
//   }

//   const accounts = await ethereum.request({ method: 'eth_accounts' });

//   if (accounts.length !== 0) {
//     const account = accounts[0];
//     currentAccount.value = account;
//   } else {
//     console.log('No authorized accounts');
//   }
// }

// onMounted(() => {
//   checkIfWalletIsConnected();
// });
</script>

<template>
  <AppHeader />
  <router-view v-slot="{ Component }">
    <keep-alive>
      <component :is="Component" :key="$route.name" />
    </keep-alive>
  </router-view>
  <ReloadPrompt />
</template>

<style>
@import './assets/base.css';
</style>
