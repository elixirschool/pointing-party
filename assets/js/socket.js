import { Socket, Presence } from 'phoenix'
const socket = new Socket('/socket', {params: {username: window.pointingParty.username}})
socket.connect()

let driving = false;

const startButton = document.querySelector('.start-button')
startButton.addEventListener('click', e => {
  driving = true;
  // send 'start_pointing' message to the channel here
})

const nextCardButtons = document.getElementsByClassName('next-card')
for (let i = 0;i < nextCardButtons.length; i++) {
  nextCardButtons[i].addEventListener('click', e => {
    // send 'finalized_points' message to the channel here
  })
}

document
  .querySelector('.calculate-points')
  .addEventListener('click', event => {
    const storyPoints = document.querySelector('.story-points')
    // send 'user_estimated' to the channel here
  })

// call the relevant function defined below when you receive the following events from the channel:
// 'next_card'
// 'winner'
// 'tie'

function showCard(state) {
  document
    .querySelector('.start-button')
    .style.display = "none"
  document
    .querySelector('.winner')
    .style.display = "none"
  document
    .querySelector('.tie')
    .style.display = "none"
  document
    .querySelector('.calculate-points')
    .style.display = "inline-block"
  document
    .querySelector('.ticket')
    .style.display = "block"
  document
    .querySelector('.ticket-title')
    .innerHTML = state.card.title
  document
    .querySelector('.ticket-description')
    .innerHTML = state.card.description
}

function showWinner(state) {
  document
    .querySelector('.winner')
    .style.display = "block"
  document
    .querySelector('.calculate-points')
    .style.display = "none"
  document
    .querySelector('.final-points')
    .innerHTML = "Winner: " + state.points + " Points"
  document
    .querySelector('.next-card')
    .value = state.points
  document
    .querySelector('.next-card')
    .disabled = !driving
}

function showTie(state) {
  document
    .querySelector('.tie')
    .style.display = "block"
  document
    .querySelector('.calculate-points')
    .style.display = "none"
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[0]
    .value = state.points[0]
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[0]
    .innerHTML = state.points[0] + " Points"
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[0]
    .disabled = !driving
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[1]
    .value = state.points[1]
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[1]
    .innerHTML = state.points[1] + " Points"
  document
    .querySelector('.tie')
    .getElementsByClassName('next-card')[1]
    .disabled = !driving
}

export default socket
