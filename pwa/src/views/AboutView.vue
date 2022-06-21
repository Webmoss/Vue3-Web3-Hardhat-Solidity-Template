<template>
  <section id="content">
    <div class="main">
      <section id="about">
        <NotConnectedForm v-model="currentAccount" v-if="!currentAccount" />
        <InputForm v-if="currentAccount" />
        <p>
          an Instant File Sharing powered by IPFS Protocol. Build with
          <a href="https://v3.vuejs.org/" target="_blank" rel="noopener">Vue 3</a> and
          <a href="https://vitejs.dev/" target="_blank" rel="noopener">ViteJS</a>.
        </p>
        <p>
          Mojo is a web-based application that uploads your files to Interplanetary File System
          (IPFS) Network using
          <a href="https://infura.io/product/ipfs" target="_blank" rel="noopener">Infura API</a>.
          File uploads cannot be deleted, hacked, edited, never saved to any server (decentralized)
          + are only accessable by using a hash / cid (content identifier).
        </p>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue';

import NotConnectedForm from '../components/not-connected-form.vue';
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

<style lang="scss">
section#content .main {
  section#about {
    width: 70vw;
    height: auto;

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

body.dark-theme {
  section#content .main section#about .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
