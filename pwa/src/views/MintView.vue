<template>
  <section id="content">
    <div class="main">
      <section id="connect">
        <h2>Mint an Audio/Media NFT</h2>
        <!-- Top Row -->
        <div class="row">
          <!-- Left Side -->
          <div v-if="currentAccount" class="left">
            <section id="panel-upload">
              <div class="content panel-upload--content">
                <div
                  class="panel-upload--dropzone"
                  :class="{ active: isDragged }"
                  @dragenter="onDragEnter"
                  @dragleave="onDragLeave"
                  @drop.prevent="onDropHandler"
                  @dragover.prevent
                >
                  <input type="file" multiple ref="fileRef" @change="onFileChangedHandler" />

                  <div class="dropzone-label" @click="openSelectFile">
                    <i-mdi-timer-sand v-if="fileCount > 0" class="icon-color" />
                    <i-mdi-upload v-else class="icon-color" />

                    <span>Drop files here or click to select files.</span>

                    <div class="dropzone-is-loading" :class="{ active: fileCount > 0 }">
                      <div class="dropzone-loading--bar"></div>
                    </div>
                    <span v-show="fileCount > 0"
                      >{{ fileCount - finished }} of {{ fileCount }} files being transfered.</span
                    >
                  </div>

                  <div class="dropzone-details">
                    <div class="dropzone-detail">{{ result.count }} files</div>
                    <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                  </div>
                </div>
              </div>
            </section>
          </div>
          <div v-if="!currentAccount" class="left">
            <p class="connect-message">
              Connect your MetaMask and mint your Audio/Media NFT's for your followers and
              subscribers allowing them to unlock bonus content and earn additional rewards.
            </p>
          </div>
          <!-- END Left Side -->
          <!-- Right Side -->
          <div v-if="!currentAccount" class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" btnSize="large" />
          </div>
          <div v-if="currentAccount" class="right">
            <div class="form-container">
              <h2>NFT Metadata</h2>
              <div class="input-row">
                <input type="text" placeholder="Name" v-model="name" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Description" v-model="description" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="External Url" v-model="externalUrl" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Image Url" v-model="imageUrl" />
              </div>
              <div class="input-row">
                <input type="text" v-model="backgroundColor" />
              </div>
              <div class="input-row">
                <input type="text" v-model="backgroundColor" />
              </div>
              <p class="tld">{{ attributes }}</p>
              <!-- Button Row -->
              <div v-if="currentAccount" class="button-container">
                <button class="mint-button" @click="mintNFT">Mint NFT</button>
              </div>
              <!-- END Button Row -->
            </div>
          </div>
          <!-- END Right Side */ -->
        </div>
        <!-- END Top Row -->
      </section>
    </div>
  </section>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { Notyf } from 'notyf';
import { useStore } from '../store';

import { uploadBlob } from '../services/ipfs.js';
import { fileSize } from '../services/helpers';

import { ethers } from 'ethers';
import contractAbi from '../../../artifacts/contracts/MyEpicNft.sol/MyEpicNft.json';
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
console.log('contractAbi: ', contractAbi);

export default {
  name: 'MintView',
  components: [ConnectWalletButton],
  setup() {
    // Create an instance of Notyf
    var notyf = new Notyf();

    const store = useStore();

    const fileRef = ref(null);
    const isDragged = ref(false);
    const finished = ref(0);
    const isUploading = ref(false);

    const currentAccount = ref();
    const name = ref('');
    const description = ref('');
    const externalUrl = ref('');
    const imageUrl = ref('');
    const backgroundColor = ref('ffffff');
    const attributes = ref([]);

    const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';

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

    const mintNFT = async () => {
      if (!name.value) {
        return;
      }
      if (name.value.length < 3) {
        alert('NFT name must be longer then 3');
        return;
      }

      const price = name.value.length === 3 ? '0.05' : name.value.length === 4 ? '0.03' : '0.01';

      console.log('Minting NFT name', name.value, 'with price', price);

      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();

          /* Dev Note: Reset this once Contracts deployed */
          const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi.abi, signer);
          console.log('Talk to the wallet and pay gas fees');

          let nftTxn = await contract.makeAnEpicNFT();
          console.log('Mining...please wait.');

          const receipt = await nftTxn.wait();
          console.log(nftTxn);
          if (receipt.status === 1) {
            console.log(
              `NFT Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
            );
          }

          name.value = '';
          description.value = '';
        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        console.log('error', error);
      }
    };

    /**
     * IPFS Pinning Example - Minty
     * https://docs.ipfs.io/how-to/mint-nfts-with-ipfs/#minty
     */
    // const mintToken = async (ownerAddress, metadataURI) => {
    //   // The smart contract adds an ipfs:// prefix to all URIs,
    //   // so make sure to remove it so it doesn't get added twice
    //   metadataURI = stripIpfsUriPrefix(metadataURI);

    //   // Call the mintToken smart contract function to issue a new token
    //   // to the given address. This returns a transaction object, but the
    //   // transaction hasn't been confirmed yet, so it doesn't have our token id.
    //   const tx = await this.contract.mintToken(ownerAddress, metadataURI);

    //   // The OpenZeppelin base ERC721 contract emits a Transfer event
    //   // when a token is issued. tx.wait() will wait until a block containing
    //   // our transaction has been mined and confirmed. The transaction receipt
    //   // contains events emitted while processing the transaction.
    //   const receipt = await tx.wait();
    //   for (const event of receipt.events) {
    //     if (event.event !== 'Transfer') {
    //       console.log('ignoring unknown event type ', event.event);
    //       continue;
    //     }
    //     return event.args.tokenId.toString();
    //   }

    //   throw new Error('unable to get token id');
    // };
    // const createNFTFromAssetData = async (content, options) => {
    //   // add the asset to IPFS
    //   const filePath = options.path || 'asset.bin';
    //   const basename = path.basename(filePath);

    //   // When you add an object to IPFS with a directory prefix in its path,
    //   // IPFS will create a directory structure for you. This is nice, because
    //   // it gives us URIs with descriptive filenames in them e.g.
    //   // 'ipfs://bafybeihhii26gwp4w7b7w7d57nuuqeexau4pnnhrmckikaukjuei2dl3fq/cat-pic.png' vs
    //   // 'ipfs://bafybeihhii26gwp4w7b7w7d57nuuqeexau4pnnhrmckikaukjuei2dl3fq'
    //   const ipfsPath = '/nft/' + basename;
    //   const { cid: assetCid } = await this.ipfs.add({ path: ipfsPath, content });

    //   // make the NFT metadata JSON
    //   const assetURI = ensureIpfsUriPrefix(assetCid) + '/' + basename;
    //   const metadata = await this.makeNFTMetadata(assetURI, options);

    //   // add the metadata to IPFS
    //   const { cid: metadataCid } = await this.ipfs.add({
    //     path: '/nft/metadata.json',
    //     content: JSON.stringify(metadata),
    //   });
    //   const metadataURI = ensureIpfsUriPrefix(metadataCid) + '/metadata.json';

    //   // get the address of the token owner from options,
    //   // or use the default signing address if no owner is given
    //   let ownerAddress = options.owner;
    //   if (!ownerAddress) {
    //     ownerAddress = await this.defaultOwnerAddress();
    //   }

    //   // mint a new token referencing the metadata URI
    //   const tokenId = await this.mintToken(ownerAddress, metadataURI);

    //   // format and return the results
    //   return {
    //     tokenId,
    //     metadata,
    //     assetURI,
    //     metadataURI,
    //     assetGatewayURL: makeGatewayURL(assetURI),
    //     metadataGatewayURL: makeGatewayURL(metadataURI),
    //   };
    // };
    // const getNFTMetadata = async (tokenId) => {
    //   const metadataURI = await this.contract.tokenURI(tokenId);
    //   const metadata = await this.getIPFSJSON(metadataURI);

    //   return { metadata, metadataURI };
    // };
    // const pinTokenData = async (tokenId) => {
    //   const { metadata, metadataURI } = await this.getNFTMetadata(tokenId);
    //   const { image: assetURI } = metadata;

    //   console.log(`Pinning asset data (${assetURI}) for token id ${tokenId}....`);
    //   await this.pin(assetURI);

    //   console.log(`Pinning metadata (${metadataURI}) for token id ${tokenId}...`);
    //   await this.pin(metadataURI);

    //   return { assetURI, metadataURI };
    // };
    // const pin = async (cidOrURI) => {
    //   const cid = extractCID(cidOrURI);

    //   // Make sure IPFS is set up to use our preferred pinning service.
    //   await this._configurePinningService();

    //   // Check if we've already pinned this CID to avoid a "duplicate pin" error.
    //   const pinned = await this.isPinned(cid);
    //   if (pinned) {
    //     return;
    //   }

    //   // Ask the remote service to pin the content.
    //   // Behind the scenes, this will cause the pinning service to connect to our local IPFS node
    //   // and fetch the data using Bitswap, IPFS's transfer protocol.
    //   await this.ipfs.pin.remote.add(cid, { service: config.pinningService.name });
    // };

    /**
     * Drag n Drop File Manager
     */
    const onDropHandler = ($event) => {
      if (isUploading.value) return false;
      isDragged.value = false;
      fileRef.value.files = $event.dataTransfer.files;
      onFileChangedHandler();
    };
    const openSelectFile = () => {
      if (isUploading.value) return false;

      fileRef.value.click();
    };
    const onDragEnter = () => {
      isDragged.value = true;
    };
    const onDragLeave = () => {
      isDragged.value = false;
    };
    /**
     * @param {File} file
     */
    const uploadFileHandler = async (file) => {
      const result = await uploadBlob(file);
      finished.value++;
      const { error } = result;
      if (error && error instanceof Error) notyf.error(error.message);
      return result;
    };
    const onFileChangedHandler = async () => {
      isUploading.value = true;
      store.addFiles(...fileRef.value.files);
      const files = store.files.map((file) => uploadFileHandler(file));
      try {
        let results = await Promise.all(files);
        const successfully = results.filter(({ error }) => !error);

        store.addResults(...successfully.map(({ error, data: file }) => file));
        store.resetFiles();

        fileRef.value.value = null;

        if (successfully.length > 0) {
          notyf.success(`${successfully.length} files successfully processed.`);
        }
      } catch (error) {
        notyf.error(`Oops! an error while processing your files.`);
      } finally {
        finished.value = 0;
        isUploading.value = false;
      }
    };
    const fileCount = computed(() => {
      return store.files.length;
    });
    const result = computed(() => {
      return {
        count: store.results.length,
        size: store.results.reduce((sum, result) => {
          return sum + result.file.size;
        }, 0),
      };
    });

    onMounted(() => {
      checkIfWalletIsConnected();
    });

    return {
      finished,
      fileRef,
      fileCount,
      result,
      isDragged,
      currentAccount,
      name,
      description,
      externalUrl,
      imageUrl,
      backgroundColor,
      attributes,
      fileSize,
      mintNFT,
      // mintToken,
      // createNFTFromAssetData,
      // getNFTMetadata,
      // pinTokenData,
      // pin,
      onDragEnter,
      onDragLeave,
      onDropHandler,
      openSelectFile,
      onFileChangedHandler,
      checkIfWalletIsConnected,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

section#content {
  display: flex;
  flex-direction: column;
  align-content: center;
  justify-content: center;
  height: 100%;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0 0 10px 0;
    overflow: hidden;
    @include breakpoint($medium) {
      height: 99%;
    }

    section#connect {
      height: 100%;
      color: #1a1a1a;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 10px;
      overflow: hidden;

      @include breakpoint($medium) {
        padding: 0 60px 20px;
      }

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
        height: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: flex-end;

        @include breakpoint($medium) {
          width: 60%;
        }

        .connect-message {
          max-width: 440px;
        }

        section#panel-upload {
          background-color: var(--gradient-100);
          border-top-left-radius: 1rem;
          border-top-right-radius: 1rem;
          width: 100%;
          height: 100%;

          @include breakpoint($medium) {
            margin-top: 0;
            padding-top: 0;
            border-top-left-radius: 1rem;
            border-bottom-left-radius: 1rem;
            border-top-right-radius: 0;
          }

          .panel-upload--content,
          .panel-upload--content .panel-upload--dropzone {
            width: 100%;
            height: 100%;
          }

          .panel-upload--dropzone {
            position: relative;
            cursor: pointer;
            overflow: hidden;

            display: flex;
            align-content: center;
            align-items: center;
            justify-content: center;

            &.active {
              > * {
                pointer-events: none;
              }
              .dropzone-label {
                background-color: rgba(0, 0, 0, 0.2);
              }
            }
            input {
              display: none;
            }
            .dropzone-label {
              display: flex;
              flex-direction: column;
              align-items: center;
              padding: 0.8rem;
              border-radius: 0.5rem;
              text-align: center;
              width: 80%;
              svg {
                height: 48px;
                width: 48px;
                margin-bottom: 1rem;
              }
              span {
                font-size: 0.8rem;
              }
            }
            .dropzone-details {
              position: absolute;
              display: flex;
              bottom: 1rem;
              left: 1rem;
              .dropzone-detail {
                background-color: var(--gradient-300);
                border-radius: 1rem;
                padding: 0.4rem 0.8rem;
                font-size: 0.8rem;
                margin-right: 0.6rem;
              }
            }

            .dropzone-is-loading {
              opacity: 0;
              position: relative;
              height: 4px;
              display: block;
              width: 150px;
              background-color: var(--gradient-300);
              border-radius: 2px;
              margin: 1rem 0 1rem 0;
              overflow: hidden;

              &.active {
                opacity: 1;
              }

              .dropzone-loading--bar {
                background-color: var(--gradient-800);

                &:before {
                  content: '';
                  position: absolute;
                  background-color: inherit;
                  top: 0;
                  left: 0;
                  bottom: 0;
                  will-change: left, right;
                  animation: indeterminate 2.1s cubic-bezier(0.65, 0.815, 0.735, 0.395) infinite;
                }
                &:after {
                  content: '';
                  position: absolute;
                  background-color: inherit;
                  top: 0;
                  left: 0;
                  bottom: 0;
                  will-change: left, right;
                  animation: indeterminate-short 2.1s cubic-bezier(0.165, 0.84, 0.44, 1) infinite;
                  animation-delay: 1.15s;
                }
              }
            }
          }
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;

        @include breakpoint($medium) {
          width: 40%;
        }

        .form-container {
          display: flex;
          width: 99%;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          border: 4px solid var(--gradient-100);
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          border-bottom-left-radius: 1em;
          border-bottom-right-radius: 1em;
          padding: 30px 0 30px 0;
          @include breakpoint($medium) {
            width: 100%;
            border-top-right-radius: 1rem;
            border-bottom-right-radius: 1rem;
            padding: 30px 20px;
          }

          h2 {
            font-size: 1.4rem;
            line-height: 1.5rem;
            text-align: center;
            padding-bottom: 2px;
            text-decoration: none;
            border-bottom: 1px solid;
            margin: 0 auto 10px;
            @include breakpoint($medium) {
              font-size: 1.6rem;
              line-height: 1.7rem;
            }
          }
        }

        input {
          border: 2px solid var(--gradient-100);
          border-radius: 10px;
          background-color: #fdfdfd;
          color: #1a1a1a;
          letter-spacing: 1px;
          font-size: 14px;
          width: 300px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;
        }

        input::placeholder {
          color: gray;
          letter-spacing: 2px;
        }

        input:focus {
          outline: none;
        }

        .input-row {
          position: relative;
          display: flex;
          flex-direction: row;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 10px;
        }

        .tld {
          position: absolute;
          font-size: 20px;
          font-weight: bold;
          color: white;
          /* left: -70px; */
          right: 22px;
          margin: 0;
          padding: 0;
          margin-bottom: 13px;
        }

        .mint-list {
          display: flex;
          flex-direction: row;
          flex-wrap: wrap;
          justify-content: center;
          align-items: center;
          margin-top: 20px;
        }

        .mint-item {
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          align-items: center;
          padding: 10px 15px;
          border-radius: 5px;
          margin: 10px 15px;
          font-size: 18px;
          background-color: #c4b7fa;
          color: black;
          min-width: 150px;
          max-width: fit-content;
          box-shadow: 0px 0px 10px 3px rgba(255, 255, 255, 0.2);
        }

        /* Different background-colour for every nth mint-item */
        .mint-item:nth-child(2n) {
          background-color: lightblue;
        }

        .mint-item:nth-child(3n) {
          background-color: lightpink;
        }

        .mint-item:nth-child(5n) {
          background-color: lightgreen;
        }
      }

      .button-container {
        margin: 0 auto;
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

        .mint-button {
          color: #fff;
          background-color: #08d0a5;
          font-size: 18px;
          font-weight: bold;
          width: auto;
          height: 55px;
          border: 0;
          padding-left: 115px;
          padding-right: 115px;
          border-radius: 10px;
          cursor: pointer;
        }

        .mint-button:disabled {
          background: #550072;
          color: rgb(209, 209, 209);
          cursor: not-allowed;
        }
      }

      h2 {
        font-size: 1.8rem;
        text-align: center;
        margin-block-start: 0;
        margin-block-end: 0.2em;
        @include breakpoint($medium) {
          font-size: 2.85rem;
          margin-block-start: 0.3em;
          margin-block-end: 0.2em;
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
