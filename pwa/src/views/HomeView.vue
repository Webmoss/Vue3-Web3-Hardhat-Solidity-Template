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
            Stream your favorite Audio/Media directly from content creators on the blockchain.
            Subscribe and follow your favorite artists, earn NFT's, receive bonus content and
            additional rewards.
          </p>
        </div>
      </section>
      <section id="connect">
        <h2>Connect</h2>
        <div class="row">
          <div class="left">
            <p>
              Upload your audio/media files with Mojo to the Interplanetary File System (<a
                href="https://infura.io/product/ipfs" target="_blank" rel="noopener">IPFS</a>) Network. Your content can
              never get deleted, hacked, edited and will never get
              saved to any server (100% decentralized). Share your content by using a unique hash or
              content identifier (CID)
            </p>
          </div>
          <div class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" />
            <button @click="$router.push('stream')" v-else className="stream-button">
              Let's Stream 📹
            </button>
          </div>
        </div>
      </section>
      <section id="stream">
        <div class="left">
          <h2>Find your groove</h2>
          <ul class="category-list">
            <li v-for="category of categories" :key="category" @click="selectCategory(category)"
              :class="categorySelectedId === category.id ? 'li-active' : ''">
              <PlayButtonWhite v-if="categorySelectedId === category.id" class="category-list-play-button" />{{
                  category.label
              }}
            </li>
          </ul>
        </div>
        <div class="right">
          <TrackPlayer v-for="track in categoryTracks" :track="track" :key="track.id"></TrackPlayer>
        </div>
      </section>
      <section id="tracks">
        <h2>Latest Playlists</h2>
        <div class="row">
          <TrackPlayer v-for="track in categoryTracks" :track="track" :key="track.id"></TrackPlayer>
        </div>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue';
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
import PlayButtonWhite from '../components/icons/PlayButtonWhite.vue';
import TrackPlayer from '../components/TrackPlayer.vue';
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

/* Track Player */
const categories = ref([
  { id: 1, label: 'Fresh Jams' },
  { id: 2, label: 'Dance & Electronica' },
  { id: 3, label: 'Pop' },
  { id: 4, label: 'Jazz & Classical' },
  { id: 5, label: 'World & Ethnic' },
  { id: 6, label: 'Cinematic & Soundscapes' },
  { id: 7, label: 'More' },
]);

const categorySelectedId = ref(1);
const categoryTracks = ref(null);

function selectCategory(category) {
  console.log('Selected Category:', category);
  categorySelectedId.value = category.id;
  console.log('categorySelectedId:', categorySelectedId.value);
}
async function fetchData() {
  categoryTracks.value = null;
  const res = await fetch(`./tracks/${categorySelectedId.value}.json`);
  console.log('Tracks Loaded:', res);
  categoryTracks.value = await res.json();
}
fetchData();
watch(categorySelectedId, fetchData);

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

    section#stream {
      color: #212121;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;

      @include breakpoint($medium) {
        flex-direction: row;
        align-content: center;
        align-items: flex-start;
        justify-content: center;
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
        display: inline-block;

        padding: 40px 20px;
      }

      h2 {
        font-size: 2.45rem;
        margin: 0;
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

    section#tracks {
      color: #fff;
      background: #1a1a1a;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 60px;

      .row {
        width: 100%;
        display: inline-block;
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
