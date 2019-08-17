import { Socket, Presence } from 'phoenix'
import updateUsers  from './users'

const socket = new Socket('/socket', {params: {username: window.pointingParty.username}})
socket.connect()

const channel = socket.channel('room:lobby', {})
const presence = new Presence(channel)

presence.onSync(() => updateUsers(presence))

let driving = false

if (window.pointingParty.username) {
  channel.join()
    .receive('ok', resp => { console.log('Joined successfully', resp) })
    .receive('error', resp => { console.log('Unable to join', resp) })
}

const startButton = document.querySelector('.start-button')
startButton.addEventListener('click', event => {
  driving = true;
  channel.push('start_pointing', {})
})

document
  .querySelectorAll('.next-card')
  .forEach(elem => {
    elem.addEventListener('click', event => {
      channel.push('finalized_points', {points: event.target.value})
    })
  })

document
  .querySelector('.calculate-points')
  .addEventListener('click', event => {
    const storyPoints = document.querySelector('.story-points')
    channel.push('user_estimated', {points: storyPoints.value})
  })

channel.on('new_card', state => {
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
})

const renderVotingResults = template => {
  const pointContainer = document.querySelector('.points-container')
  renderTemplate(pointContainer, template)

  document
    .querySelector('.next-card')
    .addEventListener('click', e => {
      channel.push('finalized_points', { points: e.target.value })
    })
}

channel.on('winner', state => {
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
})

channel.on('tie', state => {
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
})

export default socket
