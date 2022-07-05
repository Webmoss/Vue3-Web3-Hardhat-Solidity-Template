import { defineStore } from 'pinia';
import Storage from '../services/storage';

const db = new Storage('app');

db.read();
db.data ||= { version: '0.0.1', playResults: [], results: [] };

export const useStore = defineStore({
  id: 'store',
  state() {
    return {
      user: {},
      playlists: [],
      playResults: db.data.playResults,
      files: [],
      results: db.data.results,
    };
  },
  actions: {
    updateUser(...user) {
      this.user = { ...user };
    },
    resetPlaylists() {
      this.playlists = [];
    },
    addPlaylists(...playlists) {
      this.playlists.push(...playlists);
    },
    addPlayResults(...playlists) {
      this.playResults.push(...playlists);
      this.playResults = this.playResults.filter(({ cid }) => !!cid);

      db.data.playResults = [...this.playResults];
      db.write();
    },
    resetFiles() {
      this.files = [];
    },
    addFiles(...files) {
      this.files.push(...files);
    },
    addResults(...files) {
      this.results.push(...files);
      this.results = this.results.filter(({ cid }) => !!cid);

      db.data.results = [...this.results];
      db.write();
    },
    /**
     * Update Shorten Link for File
     * @param {String} cid
     * @param {String} link
     */
    updateShortenLink(cid, link) {
      this.results = this.results.map((result) => {
        if (result.cid === cid) {
          return { ...result, shorten: link };
        }

        return result;
      });

      db.data.results = [...this.results];
      db.write();
    },
  },
});
