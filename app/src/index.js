import Web3 from "web3";
import {default as contract} from '@truffle/contract';
import ElectionArtifact from "../../build/contracts/Election.json";

const truffleContract = require('@truffle/contract');

var App = {
  web3Provider: null,
  contracts: {},
  account: '0x00',
  accounts: null,
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: async function() {
    if (window.ethereum) {
      // use MetaMask's provider
      App.web3Provider = new Web3(window.ethereum);
      await window.ethereum.enable();
      console.log("Connected to window.ethereum") // get permission to access accounts
    }

    return App.initContract();
  },

  initContract: async function() {
  
    try {
      App.contracts.Election = contract(ElectionArtifact);
      App.contracts.Election.setProvider(web3.currentProvider);

      // get accounts
      const accounts = await App.web3Provider.eth.getAccounts();
      App.account = accounts[0];
      $("#accountAddress").html("Your Account Address: " + App.account);
      console.log("INITContract", App.contracts)

      // RenderApp.listenForEvents();

      
      return App.render();
    } catch (error) {
      console.log(error);
      console.error("Could not connect to contract or chain.");
    }
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Election.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.votedEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },

  render: function() {
    var electionInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    //content.hide();

    // Acccounts now exposed
    window.ethereum.on('accountsChanged', function () {
      App.web3Provider.eth.getAccounts(function (error, accounts) {
        if (error === null) { 
          App.account = accounts[0];
          $("#accountAddress").html("Your Account Address: " + App.account);
        }
      });
    });

    // Load contract data
    App.contracts.Election.deployed().then(function(instance) {
      electionInstance = instance;
      return electionInstance.candidatesCount();
    }).then(function(candidatesCount) {
      var candidatesResults = $("#candidatesResults");
      candidatesResults.empty();

      var candidatesSelect = $('#candidatesSelect');
      candidatesSelect.empty();

      for (var i = 1; i <= candidatesCount; i++) {
        electionInstance.candidates(i).then(function(candidate) {
          var id = candidate[0];
          var name = candidate[1];
          var party = candidate[2];
          var voteCount = candidate[3];

          // Render candidate Result
          var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + party + "</td><td>" + voteCount + "</td></tr>"
          candidatesResults.append(candidateTemplate);

          // Render candidate ballot option
          var candidateOption = "<option value='" + id + "' >" + name + "</ option>"
          candidatesSelect.append(candidateOption);
        });
      }
      return electionInstance.voters(App.account);
    }).then(function(hasVoted) {
      // Do not allow a user to vote
      if(hasVoted) {
        $('form').hide();
      }
      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });
  },

  castVote: function() {
    var candidateId = $('#candidatesSelect').val();
    App.contracts.Election.deployed().then(function(instance) {
      return instance.vote(candidateId, { from: App.account });
    }).then(function(result) {
      // Wait for votes to update
      $("#content").hide();
      $("#loader").show();
    }).catch(function(err) {
      console.error(err);
    });
  }
};

$(function() {
  $(window).on('load', function() {
    App.init();
  });
});