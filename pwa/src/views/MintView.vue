<template>
  <section id="content">
    <div class="main">
      <div class="main-content">
        <section id="mint">
          <h1>Mint NFT</h1>
          <p>
            🎧 Mojo is a web-based application that uploads your files to Interplanetary File System
            (IPFS) Network using
            <a href="https://infura.io/product/ipfs" target="_blank" rel="noopener">Infura API</a>.
            File uploads cannot be deleted, hacked, edited, never saved to any server
            (decentralized) + are only accessable by using a hash / cid (content identifier).
          </p>
          <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" />
          <InputForm v-if="currentAccount" />
        </section>
      </div>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue';

import ConnectWalletButton from '../components/ConnectWalletButton.vue';
import InputForm from '../components/input-form.vue';

const currentAccount = ref();

async function checkIfWalletIsConnected() {
  const { ethereum } = window;

  if (!ethereum) {
    console.log('Error: No ethereum window object');
    return;
  } else {
    console.log('we have an ethereum object', ethereum);
  }

  const accounts = await ethereum.request({ method: 'eth_accounts' });

  if (accounts.length !== 0) {
    const account = accounts[0];
    currentAccount.value = account;
  } else {
    console.log('No authorized accounts');
  }
}

onMounted(() => {
  checkIfWalletIsConnected();
});
</script>

<style lang="scss" scoped>
section#content {
  position: relative;
  height: 100%;

  .main {
    display: flex;
    align-content: center;
    align-items: center;
    justify-content: center;

    height: 100%;

    .main-content {
      position: absolute;
      z-index: 3;

      display: flex;
      border-radius: 1em;
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);

      section {
        width: 70vw;
        height: 414px;
      }
    }

    section#mint {
      h1 {
        img {
          display: inline-block;
        }
      }

      a {
        color: var(--contrast-color);
        font-weight: bold;
        border-bottom: 1px solid var(--contrast-color);
        text-decoration: none;

        &.author {
          padding: 6px 12px;
          border-radius: 8px;
          background-color: var(--gradient-100);
          color: var(--icon-color);
          font-size: 0.85rem;

          border-bottom: none;
        }
      }

      p {
        line-height: 1.7;
      }

      .icon-love {
        color: #e91e63;
        display: inline;
        vertical-align: middle;
      }
    }
  }
}

body.dark-theme {
  section#content .main section#mint .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .mint {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
