<template>
  <section id="content">
    <div class="main">
      <section id="home">
        <div class="left">
          <div class="player-graphic">
            <img src="../assets/images/DJ.png" alt="DJ Saved my Life" />
          </div>
        </div>
        <div class="right">
          <h1>Hear It, See It, Live it.</h1>
          <p>
            Stream your favorite Audio and Media directly from artists and creators on the
            blockchain. Subscribe and follow to earn special rewards and NFT's
          </p>
        </div>
      </section>
      <section id="connect">
        <h2>Connect</h2>
        <div class="row">
          <p>
            🎧 Mojo uploads your files to Interplanetary File System (<a href="https://infura.io/product/ipfs"
              target="_blank" rel="noopener">IPFS</a>) Network.
          </p>
          <p>
            File uploads can never get deleted, hacked, edited and never saved to any server (100%
            decentralized).
          </p>
          <p>Share your content by using a hash / cid (content identifier)</p>
        </div>
      </section>
      <section id="about">
        <h2>About</h2>
        <div class="left">
          <p>
            🎧 Mojo is an Instant File Sharing powered by IPFS Protocol. Build with
            <a href="https://v3.vuejs.org/" target="_blank" rel="noopener">Vue 3</a> and
            <a href="https://vitejs.dev/" target="_blank" rel="noopener">ViteJS</a>.
          </p>
        </div>
        <div class="right">
          <p>
            🎧 Mojo is a web-based application that uploads your files to Interplanetary File System
            (IPFS) Network using
            <a href="https://infura.io/product/ipfs" target="_blank" rel="noopener">Infura API</a>.
            File uploads cannot be deleted, hacked, edited, never saved to any server
            (decentralized) + are only accessable by using a hash / cid (content identifier).
          </p>
        </div>
      </section>
      <section id="tracks">
        <h2>Latest Tracks</h2>
        <div class="left">
          <p>
            🎧 Mojo is a web-based application that uploads your files to Interplanetary File System
            (IPFS) Network using
            <a href="https://infura.io/product/ipfs" target="_blank" rel="noopener">Infura API</a>.
            File uploads cannot be deleted, hacked, edited, never saved to any server
            (decentralized) + are only accessable by using a hash / cid (content identifier).
          </p>
        </div>
        <div class="right"></div>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue';
// Icons
import HomeIcon from '../assets/svgs/HomeIcon.vue';

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
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#home {
      color: #212121;
      background: #ffca28;
      display: flex;
      flex-direction: row;
      align-content: center;
      align-items: center;
      justify-content: space-between;
      padding: 20px;

      .left {
        width: 55%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        padding: 20px;

        .player-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0;
          overflow: hidden;

          img,
          svg {
            width: 100%;
            height: 100%;
            object-fit: cover;
            overflow: hidden;
          }
        }
      }

      .right {
        width: 45%;
        display: flex;
        flex-direction: column;
        align-content: flex-start;
        justify-content: flex-start;
      }

      h1 {
        font-size: 4.55rem;
        margin-bottom: 20px;
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
        margin-bottom: 20px;
      }
    }

    section#connect {
      color: #1a1a1a;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-content: center;
      justify-content: space-between;
      padding: 20px;

      .row {
        display: flex;
        flex-direction: row;
        align-content: center;
        align-content: center;
        justify-content: space-between;
        padding: 20px;
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
      }

      .graphic {
        width: 100%;
      }
    }

    section#about {
      color: #212121;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: flex-start;
      justify-content: center;
      padding: 20px;

      .left {
        width: 70%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
      }

      .right {
        width: 30%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
      }

      h1 {
        img {
          display: inline-block;
        }
      }

      a {
        color: #1a1a1a;
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
        margin-bottom: 20px;
      }
    }

    section#tracks {
      color: #fff;
      background: #1a1a1a;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 20px;

      .left {
        width: 30%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
      }

      .right {
        width: 70%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
      }

      h2 {
        font-size: 2.85rem;
        text-align: center;
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
        margin-bottom: 20px;
      }
    }
  }
}

body.dark-theme {
  section#content .main section#home .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .home {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
