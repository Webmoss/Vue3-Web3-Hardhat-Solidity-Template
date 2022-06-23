<script setup>
defineProps({
  currentAccount: String,
});

const emit = defineEmits(['update:modelValue']);

async function connectWallet() {
  const { ethereum } = window;
  try {
    if (!ethereum) {
      alert('Please install Metamask!');
      return;
    }

    const accounts = await ethereum.request({
      method: 'eth_requestAccounts',
    });
    emit('update:modelValue', accounts[0]);
    console.log('Accounts', accounts[0]);
  } catch (error) {
    console.log('Error', error);
  }
}
</script>
<template>
  <div className="connect-wallet-container">
    <button @click="connectWallet" className="connect-wallet-button">🎧 Connect Wallet</button>
  </div>
</template>
