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
          <h1>Hear it, See it, Live it.</h1>
          <p>
            Get you Mojo on and stream Audio/Media directly from your favorite content creators on
            the blockchain. Subscribe and follow artists and digital content creators, purchase a
            custom NFT's and receive additional content, rewards and more.
          </p>
        </div>
      </section>
      <section id="stream">
        <h2>Latest Tracks</h2>
        <div class="row">
          <TrackPlayer v-for="track in categoryTracks" :track="track" :key="track.id"></TrackPlayer>
        </div>
      </section>
      <section id="connect">
        <h2>Connect</h2>
        <div class="row">
          <div class="left">
            <p>
              Upload your audio/media files with Mojo to the Interplanetary File System (<a
                href="https://infura.io/product/ipfs"
                target="_blank"
                rel="noopener"
                >IPFS</a
              >) Network. Your content can never get deleted, hacked, edited and will never get
              saved to any server (100% decentralized). Share your content by using a unique hash or
              content identifier (CID)
            </p>
          </div>
          <div class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" btnSize="large" />
            <button @click="$router.push('stream')" v-if="currentAccount" className="stream-button">
              Let's Stream 🎶
            </button>
            <button @click="$router.push('upload')" v-if="currentAccount" className="upload-button">
              Upload Files 🎤
            </button>
            <button
              @click="$router.push('mint')"
              v-if="currentAccount"
              className="mint-media-button"
            >
              Create Content 🧪
            </button>
          </div>
        </div>
      </section>
      <section id="royalties">
        <div class="row">
          <div class="left">
            <h1>Royalties</h1>
            <h2>
              Your streams directly support
              <span class="yellow">artists &amp; content creators</span>.
            </h2>
          </div>
          <div class="right">
            <div class="royalty-graphic">
              <img src="../assets/images/RoyaltyFees.jpeg" alt="Royalty Fees" />
            </div>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import { Notyf } from 'notyf';
/* Components */
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
import TrackPlayer from '../components/TrackPlayer.vue';

// Create an instance of Notyf
var notyf = new Notyf();

const currentAccount = ref('');

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

const categoryTracks = ref(null);

async function fetchData() {
  categoryTracks.value = null;
  const res = await fetch(`./tracks/1.json`);
  console.log('Tracks Loaded:', res);
  categoryTracks.value = await res.json();
}
fetchData();

onMounted(() => {
  checkIfWalletIsConnected();
  console.log('currentAccount: ', currentAccount);
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

    section#home {
      color: #212121;
      background: #ffca28;
      border-bottom: 1px solid #1a1a1a;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 60px 60px 60px 0;

      @include breakpoint($medium) {
        flex-direction: row;
        align-content: center;
        align-items: center;
        justify-content: space-between;
        padding: 60px 60px 60px 0;
      }

      .left {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        padding: 0;

        @include breakpoint($medium) {
          width: 55%;
        }

        .player-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0 10px;
          overflow: hidden;

          @include breakpoint($medium) {
            padding: 0;
          }

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
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        padding: 0 0 0 20px;

        @include breakpoint($medium) {
          width: 45%;
          align-content: flex-start;
          justify-content: flex-start;
          padding: 0 0 0 20px;
        }
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

    section#stream {
      color: #fff;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 60px;

      .row {
        width: 100%;
        max-width: 960px;
        display: inline-block;
        margin: 40px auto;
      }

      .left {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        padding: 50px 20px 60px 60px;

        @include breakpoint($medium) {
          width: 29%;
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 40px 20px;
        .track-list {
          width: 100%;
          max-width: 960px;
          display: inline-block;
          margin: 0 auto;
        }
      }

      h2 {
        font-size: 2.45rem;
        margin: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
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

      ul.category-list {
        list-style-type: none;
        list-style-position: outside;
        margin-block-start: 1em;
        margin-block-end: 1em;
        margin-inline-start: 0px;
        margin-inline-end: 0px;
        padding-inline-start: 0;
        border-top: 1px solid #1a1a1a;

        li {
          font-size: 22px;
          font-weight: 700;
          line-height: 1.75rem;
          padding-top: 0.75rem;
          padding-bottom: 0.75rem;
          padding-left: 1rem;
          padding-right: 1rem;
          border-bottom: 1px solid #1a1a1a;

          &:hover {
            color: #fff;
            cursor: pointer;
          }

          &:active {
            color: #fff;
            font-weight: 600;
          }
        }
      }

      .li-active {
        color: #fff;
        font-weight: 600;
      }

      .category-list-play-button {
        margin: 0 5px 0 -15px;
      }
    }

    section#connect {
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
        flex-direction: column;
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
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
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

    section#royalties {
      color: #fff;
      background: #1a1a1a;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 60px;

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
        flex-direction: column;
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

        .royalty-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0 10px;
          overflow: hidden;

          @include breakpoint($medium) {
            padding: 0;
          }

          img,
          svg {
            width: 100%;
            height: 100%;
            object-fit: cover;
            overflow: hidden;
          }
        }
      }

      h1 {
        color: #2bb5f0;
        font-size: 2.85rem;
        text-align: center;
        margin-bottom: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      h2 {
        font-size: 2.25rem;
        text-align: center;
        .yellow {
          color: #ffca28;
        }
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
  section#content .main section#home {
    border-bottom: 1px solid #ffffff;
  }

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
