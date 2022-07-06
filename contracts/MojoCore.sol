// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
/* Taken from https://gist.github.com/ilamanov/e4241e5b8afd0cb2341c544363899f8b for learning purposes */

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

// We import helper functions for Solidity
import { StringUtils } from './libraries/StringUtils.sol';
import { Base64 } from './libraries/Base64.sol';

import 'hardhat/console.sol';

contract MojoCore is CustomERC721Metadata, ERC721URIStorage {

   /* Magic given to us by OpenZeppelin to help us keep track of tokenIds. */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using SafeMath for uint256;

    event Mint(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _trackId

    );

    struct Track {
        string name;
        string artist;
        string description;
        string website;
        string license;
        bool active;
        bool locked;
        bool paused;

        /* Number of NFTs minted for this track */
        uint256 invocations;
        uint256 maxInvocations;

        /* Whether project dynamic or static */
        bool dynamic;
        /* if track is dynamic, tokenUri will be "{trackBaseURI}/{tokenId}" */
        string trackBaseURI;
        /* if track is static, we will use IPFS */
        bool useIpfs;
        /* tokenUri will be "{trackBaseIpfsURI}/{ipfsHash}" */
        string trackBaseIpfsURI;
        string ipfsHash;

        /* if true, hash is used as an input to generate the image */
        bool useHashString;

    }

    uint256 constant ONE_MILLION = 1_000_000;

    /**
     * NFTs for all tracks are stored in one big smart contract
     * we don’t create a new contract for each collection.
     * All the tracks are stored in one big mapping, called tracks,
     * where the key is just the index of the track (0,1,2,…):
     */
    mapping(uint256 => Track) tracks;

    /* All financial functions are stripped from struct for visibility */
    mapping(uint256 => address) public trackIdToArtistAddress;
    mapping(uint256 => string) public trackIdToCurrencySymbol;
    mapping(uint256 => address) public trackIdToCurrencyAddress;
    mapping(uint256 => uint256) public trackIdToPricePerTokenInWei;
    mapping(uint256 => address) public trackIdToAdditionalPayee;
    mapping(uint256 => uint256) public trackIdToAdditionalPayeePercentage;
    mapping(uint256 => uint256) public trackIdToSecondaryMarketRoyaltyPercentage;

    mapping(uint256 => string) public staticIpfsImageLink;

    /**
     * tokenId is the ID of an NFT and trackId is the ID of the track.
     * The contract keeps track of the 2-way mapping between the two.
     */
    mapping(uint256 => uint256) public tokenIdToTrackId;
    mapping(uint256 => uint256[]) internal trackIdToTokenIds;

    address public mojoAddress;
    uint256 public mojoPercentage = 10;

    address public admin;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isMintWhitelisted;

    uint256 public nextTrackId = 3;

    modifier onlyValidTokenId(uint256 _tokenId) {
        require(_exists(_tokenId), "Token ID does not exist");
        _;
    }

    modifier onlyUnlocked(uint256 _trackId) {
        require(!tracks[_trackId].locked, "Only if unlocked");
        _;
    }

    modifier onlyArtist(uint256 _trackId) {
        require(msg.sender == trackIdToArtistAddress[_trackId], "Only artist");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender], "Only whitelisted");
        _;
    }

    modifier onlyArtistOrWhitelisted(uint256 _trackId) {
        require(isWhitelisted[msg.sender] || msg.sender == trackIdToArtistAddress[_trackId], "Only artist or whitelisted");
        _;
    }

    constructor(string memory _tokenName, string memory _tokenSymbol) CustomERC721Metadata(_tokenName, _tokenSymbol) public {
        admin = msg.sender;
        isWhitelisted[msg.sender] = true;
        mojoAddress = msg.sender;
        console.log('Admin %s', admin);
        console.log("This is my NFT track. Let the Mojo Go!!");
    }

    function mint(address _to, uint256 _trackId, address _by) external returns (uint256 _tokenId) {
        require(isMintWhitelisted[msg.sender], "Must mint from whitelisted minter contract.");
        require(tracks[_trackId].invocations.add(1) <= tracks[_trackId].maxInvocations, "Must not exceed max invocations");
        require(tracks[_trackId].active || _by == trackIdToArtistAddress[_trackId], "Track must exist and be active");
        require(!tracks[_trackId].paused || _by == trackIdToArtistAddress[_trackId], "Purchases are paused.");

        uint256 tokenId = _mintToken(_to, _trackId);

        return tokenId;
    }

    function _mintToken(address _to, uint256 _trackId) internal returns (uint256 _tokenId) {
        /**
         * The tokenId for the NFT starts at index=trackId * 1,000,000
         * For example, the 3rd NFT in the Example track (which is the 12th track)
         * will have a tokenId=12000003
         */
        uint256 tokenIdToBe = (_trackId * ONE_MILLION) + tracks[_trackId].invocations;

        tracks[_trackId].invocations = tracks[_trackId].invocations.add(1);


            // bytes32 hash = keccak256(abi.encodePacked(tracks[_trackId].invocations, block.number, blockhash(block.number - 1), msg.sender, randomizerContract.returnValue()));
            // tokenIdToHash[tokenIdToBe]=hash;
            // hashToTokenId[hash] = tokenIdToBe;

        /* DEV NOTE: Need to replace this part, used the Randomiser thingy */


        _mint(_to, tokenIdToBe);

        console.log('\n--------------------------------------------------------');
        console.log('tokenIdToBe', tokenIdToBe);
        console.log('--------------------------------------------------------\n');

        tokenIdToTrackId[tokenIdToBe] = _trackId;
        trackIdToTokenIds[_trackId].push(tokenIdToBe);

        emit Mint(_to, tokenIdToBe, _trackId);

        return tokenIdToBe;
    }

    function updateMojoAddress(address _mojoAddress) public onlyAdmin {
        mojoAddress = _mojoAddress;
    }

    function updateMojoPercentage(uint256 _mojoPercentage) public onlyAdmin {
        require(_mojoPercentage <= 15, "Maximum of 15%");
        mojoPercentage = _mojoPercentage;
    }

    function addWhitelisted(address _address) public onlyAdmin {
        isWhitelisted[_address] = true;
    }

    function removeWhitelisted(address _address) public onlyAdmin {
        isWhitelisted[_address] = false;
    }

    function addMintWhitelisted(address _address) public onlyAdmin {
        isMintWhitelisted[_address] = true;
    }

    function removeMintWhitelisted(address _address) public onlyAdmin {
        isMintWhitelisted[_address] = false;
    }

    /**
     *  Once the track is locked, many variables can never be changed by Modifier onlyUnlocked
     */
    function toggleTrackIsLocked(uint256 _trackId) public onlyWhitelisted onlyUnlocked(_trackId) {
        tracks[_trackId].locked = true;
    }

    function toggleTrackIsActive(uint256 _trackId) public onlyWhitelisted {
        tracks[_trackId].active = !tracks[_trackId].active;
    }

    function updateTrackArtistAddress(uint256 _trackId, address _artistAddress) public onlyArtistOrWhitelisted(_trackId) {
        trackIdToArtistAddress[_trackId] = _artistAddress;
    }

    function toggleTrackIsPaused(uint256 _trackId) public onlyArtist(_trackId) {
        tracks[_trackId].paused = !tracks[_trackId].paused;
    }

    function addTrack(
              string memory _trackName,
              address _artistAddress,
              uint256 _pricePerTokenInWei,
              bool _dynamic) public onlyWhitelisted {

        uint256 trackId = nextTrackId;
        trackIdToArtistAddress[trackId] = _artistAddress;
        tracks[trackId].name = _trackName;
        trackIdToCurrencySymbol[trackId] = "ETH";
        trackIdToPricePerTokenInWei[trackId] = _pricePerTokenInWei;
        tracks[trackId].paused=true;
        tracks[trackId].dynamic=_dynamic;
        tracks[trackId].maxInvocations = ONE_MILLION;
        if (!_dynamic) {
            tracks[trackId].useHashString = false;
        } else {
            tracks[trackId].useHashString = true;
        }
        nextTrackId = nextTrackId.add(1);
    }

    function updateTrackCurrencyInfo(uint256 _trackId, string memory _currencySymbol, address _currencyAddress) onlyArtist(_trackId) public {
        trackIdToCurrencySymbol[_trackId] = _currencySymbol;
        trackIdToCurrencyAddress[_trackId] = _currencyAddress;
    }

    function updateTrackPricePerTokenInWei(uint256 _trackId, uint256 _pricePerTokenInWei) onlyArtist(_trackId) public {
        trackIdToPricePerTokenInWei[_trackId] = _pricePerTokenInWei;
    }

    function updateTrackName(
            uint256 _trackId,
            string memory _trackName)
            onlyUnlocked(_trackId)
            onlyArtistOrWhitelisted(_trackId) public {
        tracks[_trackId].name = _trackName;
    }

    function updateTrackArtistName(uint256 _trackId, string memory _trackArtistName) onlyUnlocked(_trackId) onlyArtistOrWhitelisted(_trackId) public {
        tracks[_trackId].artist = _trackArtistName;
    }

    function updateTrackAdditionalPayeeInfo(uint256 _trackId, address _additionalPayee, uint256 _additionalPayeePercentage) onlyArtist(_trackId) public {
        require(_additionalPayeePercentage <= 100, "Max of 100%");
        trackIdToAdditionalPayee[_trackId] = _additionalPayee;
        trackIdToAdditionalPayeePercentage[_trackId] = _additionalPayeePercentage;
    }

    function updateTrackSecondaryMarketRoyaltyPercentage(uint256 _trackId, uint256 _secondMarketRoyalty) onlyArtist(_trackId) public {
        require(_secondMarketRoyalty <= 100, "Max of 100%");
        trackIdToSecondaryMarketRoyaltyPercentage[_trackId] = _secondMarketRoyalty;
    }

    function updateTrackDescription(uint256 _trackId, string memory _trackDescription) onlyArtist(_trackId) public {
        tracks[_trackId].description = _trackDescription;
    }

    function updateTrackWebsite(uint256 _trackId, string memory _trackWebsite) onlyArtist(_trackId) public {
        tracks[_trackId].website = _trackWebsite;
    }

    function updateTrackLicense(uint256 _trackId, string memory _trackLicense) onlyUnlocked(_trackId) onlyArtistOrWhitelisted(_trackId) public {
        tracks[_trackId].license = _trackLicense;
    }

    function updateTrackMaxInvocations(uint256 _trackId, uint256 _maxInvocations) onlyArtist(_trackId) public {
        require((!tracks[_trackId].locked || _maxInvocations<tracks[_trackId].maxInvocations), "Only if unlocked");
        require(_maxInvocations > tracks[_trackId].invocations, "You must set max invocations greater than current invocations");
        require(_maxInvocations <= ONE_MILLION, "Cannot exceed 1,000,000");
        tracks[_trackId].maxInvocations = _maxInvocations;
    }

    function toggleTrackUseHashString(uint256 _trackId) onlyUnlocked(_trackId) onlyArtistOrWhitelisted(_trackId) public {
      require(tracks[_trackId].invocations == 0, "Cannot modify after a token is minted.");
      tracks[_trackId].useHashString = !tracks[_trackId].useHashString;
    }

    function updateTrackIpfsHash(uint256 _trackId, string memory _ipfsHash) onlyUnlocked(_trackId) onlyArtistOrWhitelisted(_trackId) public {
        tracks[_trackId].ipfsHash = _ipfsHash;
    }

    function updateTrackBaseURI(uint256 _trackId, string memory _newBaseURI) onlyArtist(_trackId) public {
        tracks[_trackId].trackBaseURI = _newBaseURI;
    }

    function updateTrackBaseIpfsURI(uint256 _trackId, string memory _trackBaseIpfsURI) onlyArtist(_trackId) public {
        tracks[_trackId].trackBaseIpfsURI = _trackBaseIpfsURI;
    }

    function toggleTrackUseIpfsForStatic(uint256 _trackId) onlyArtist(_trackId) public {
        require(!tracks[_trackId].dynamic, "can only set static IPFS hash for static tracks");
        tracks[_trackId].useIpfs = !tracks[_trackId].useIpfs;
    }

    function toggleTrackIsDynamic(uint256 _trackId) onlyUnlocked(_trackId) onlyArtistOrWhitelisted(_trackId) public {
      require(tracks[_trackId].invocations == 0, "Can not switch after a token is minted.");
        if (tracks[_trackId].dynamic) {
            tracks[_trackId].useHashString = false;
        } else {
            tracks[_trackId].useHashString = true;
        }
        tracks[_trackId].dynamic = !tracks[_trackId].dynamic;
    }

    function overrideTokenDynamicImageWithIpfsLink(uint256 _tokenId, string memory _ipfsHash) onlyArtist(tokenIdToTrackId[_tokenId]) public {
        staticIpfsImageLink[_tokenId] = _ipfsHash;
    }

    function clearTokenIpfsImageUri(uint256 _tokenId) onlyArtist(tokenIdToTrackId[_tokenId]) public {
        delete staticIpfsImageLink[tokenIdToTrackId[_tokenId]];
    }

    function trackDetails(uint256 _trackId) view public returns (string memory trackName, string memory artist, string memory description, string memory website, string memory license, bool dynamic) {
        trackName = tracks[_trackId].name;
        artist = tracks[_trackId].artist;
        description = tracks[_trackId].description;
        website = tracks[_trackId].website;
        license = tracks[_trackId].license;
        dynamic = tracks[_trackId].dynamic;
    }

    function trackTokenInfo(uint256 _trackId) view public returns (address artistAddress, uint256 pricePerTokenInWei, uint256 invocations, uint256 maxInvocations, bool active, address additionalPayee, uint256 additionalPayeePercentage ,string memory currency, address currencyAddress) {
        artistAddress = trackIdToArtistAddress[_trackId];
        pricePerTokenInWei = trackIdToPricePerTokenInWei[_trackId];
        invocations = tracks[_trackId].invocations;
        maxInvocations = tracks[_trackId].maxInvocations;
        active = tracks[_trackId].active;
        additionalPayee = trackIdToAdditionalPayee[_trackId];
        additionalPayeePercentage = trackIdToAdditionalPayeePercentage[_trackId];
        currency = trackIdToCurrencySymbol[_trackId];
        currencyAddress = trackIdToCurrencyAddress[_trackId];
    }

    function trackURIInfo(uint256 _trackId) view public returns (string memory trackBaseURI, string memory trackBaseIpfsURI, bool useIpfs) {
        trackBaseURI = tracks[_trackId].trackBaseURI;
        trackBaseIpfsURI = tracks[_trackId].trackBaseIpfsURI;
        useIpfs = tracks[_trackId].useIpfs;
    }

    function trackShowAllTokens(uint _trackId) public view returns (uint256[] memory){
        return trackIdToTokenIds[_trackId];
    }

    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }

    function getRoyaltyData(uint256 _tokenId) public view returns (address artistAddress, address additionalPayee, uint256 additionalPayeePercentage, uint256 royaltyFeeByID) {
        artistAddress = trackIdToArtistAddress[tokenIdToTrackId[_tokenId]];
        additionalPayee = trackIdToAdditionalPayee[tokenIdToTrackId[_tokenId]];
        additionalPayeePercentage = trackIdToAdditionalPayeePercentage[tokenIdToTrackId[_tokenId]];
        royaltyFeeByID = trackIdToSecondaryMarketRoyaltyPercentage[tokenIdToTrackId[_tokenId]];
    }

    /* Want to use Tableland */
    function tokenURI(uint256 _tokenId) external view onlyValidTokenId(_tokenId) returns (string memory) {
        if (bytes(staticIpfsImageLink[_tokenId]).length > 0) {
            return Strings.strConcat(tracks[tokenIdToTrackId[_tokenId]].trackBaseIpfsURI, staticIpfsImageLink[_tokenId]);
        }

        if (!tracks[tokenIdToTrackId[_tokenId]].dynamic && tracks[tokenIdToTrackId[_tokenId]].useIpfs) {
            return Strings.strConcat(tracks[tokenIdToTrackId[_tokenId]].trackBaseIpfsURI, tracks[tokenIdToTrackId[_tokenId]].ipfsHash);
        }

        return Strings.strConcat(tracks[tokenIdToTrackId[_tokenId]].trackBaseURI, Strings.uint2str(_tokenId));
    }
}
