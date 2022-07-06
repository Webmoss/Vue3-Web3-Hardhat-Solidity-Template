<template>
  <header id="header">
    <div class="header-title">
      <h1><span class="emoji">🎧</span> Mojo</h1>
      <span>Instant File Sharing powered by IPFS Protocol</span>
    </div>
    <div class="header-menu">
      <nav class="header-navbar">
        <router-link :to="{ name: 'home' }" active-class="active" exact>Home</router-link>
        <router-link :to="{ name: 'stream' }" active-class="active" exact>Stream</router-link>
        <router-link v-if="currentAccount" :to="{ name: 'upload' }" active-class="active" exact
          >Upload</router-link
        >
        <router-link v-if="currentAccount" :to="{ name: 'mint' }" active-class="active" exact
          >Mint</router-link
        >
        <div v-if="!currentAccount" class="right">
          <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" btnSize="small" />
        </div>
        <i :title="`Let's Jam ${isDark ? 'Light' : 'Dark'} Mode`">
          <i-mdi-brightness-7 v-if="isDark" class="icon-color" @click="toggleTheme" />
          <i-mdi-brightness-4 v-else class="icon-color" @click="toggleTheme" />
        </i>
      </nav>
    </div>
  </header>
</template>
<script>
import { ref, onMounted } from 'vue';
import { Notyf } from 'notyf';
/* Components */
import ConnectWalletButton from '../components/ConnectWalletButton.vue';

export default {
  name: 'AppHeader',
  components: [ConnectWalletButton],
  setup() {
    // Create an instance of Notyf
    var notyf = new Notyf();

    const currentAccount = ref();

    const isDarkClassAvailable = document.body.classList.contains('dark-theme');
    const isDark = ref(isDarkClassAvailable);

    const checkIfWalletIsConnected = async () => {
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
    };

    const toggleTheme = () => {
      document.body.classList.toggle('dark-theme');
      requestAnimationFrame(toggleAnimation);
      isDark.value = !isDark.value;
    };
    const toggleAnimation = () => {
      const element = document.querySelector('section#content .main');
      element.classList.remove('animated');
      void element.offsetWidth;
      element.classList.add('animated');
    };

    onMounted(() => {
      checkIfWalletIsConnected();
    });

    return {
      isDark,
      currentAccount,
      checkIfWalletIsConnected,
      toggleTheme,
    };
  },
};
</script>

<style lang="scss">
#header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-bottom 0.5s ease;
  padding: 1em 64px;
  border-bottom: 1px solid #1a1a1a;

  .header-title {
    h1 {
      font-size: 1.7rem;
      font-weight: 700;
      margin: 0 0 8px 0;
      color: #333;

      span.emoji {
        font-size: 1.5rem;
      }
    }

    span {
      font-size: 0.8rem;
    }
  }

  .header-menu {
    display: flex;
    align-items: center;

    nav {
      display: flex;
      align-items: center;
      text-align: right;
      padding: 0.3em;

      a {
        color: var(--contrast-color);
        margin-right: 16px;
        padding-bottom: 8px;
        text-decoration: none;

        border-bottom: 1px solid;
        cursor: pointer;

        &.active {
          font-weight: bold;
        }
      }

      svg {
        cursor: pointer;
        font-size: 2em;
      }
    }
  }
}

body.dark-theme {
  #header {
    border-bottom: 1px solid #ffffff;

    .header-title h1 {
      color: #ffffff;
    }
  }
}
</style>
