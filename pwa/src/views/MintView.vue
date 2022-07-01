<template>
  <section id="content">
    <div class="main">
      <section id="connect">
        <h2>Mint NFT</h2>
        <div class="row">
          <div class="left">
            <p>
              Mint NFT's for your followers and subscribers allowing them to unlock bonus content
              and earn additional rewards.'
            </p>
          </div>
          <div class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" />
            <InputForm v-if="currentAccount" />
          </div>
        </div>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref, inject } from 'vue';

import ConnectWalletButton from '../components/ConnectWalletButton.vue';
import InputForm from '../components/input-form.vue';

const notyf = inject('notyf');
const currentAccount = ref();

async function checkIfWalletIsConnected() {
  try {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;

    if (!ethereum) {
      notyf.error(`Please connect Metamask to continue!`);
      console.log('Error: No ethereum window object');
      return;
    } else {
      console.log('We have an ethereum object', ethereum);
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      currentAccount.value = account;
    } else {
      console.log('No authorized accounts');
    }
  } catch (error) {
    console.log(error);
  }
}

onMounted(() => {
  checkIfWalletIsConnected();
});
</script>

<style lang="scss" scoped>
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

section#content {
  position: relative;
  height: 100%;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#connect {
      height: 100%;
      color: #1a1a1a;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 20px 60px 60px;

      .row {
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
        }
      }

      .left {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          width: 50%;
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          width: 50%;
        }
      }

      h2 {
        font-size: 2.85rem;
        text-align: center;
      }

      a {
        color: #1a1a1a;
        font-weight: bold;
        border-bottom: 1px solid #1a1a1a;
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
        margin-bottom: 20px;
        text-align: center;
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
