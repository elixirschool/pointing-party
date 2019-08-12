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

const renderTemplate = function(parent, template) {
  while (parent.firstChild) {
    parent.removeChild(parent.firstChild)
  }

  const fragment = document.createRange().createContextualFragment(template)
  parent.appendChild(fragment)
}

// const startButton = document.querySelector('.start-button')
// startButton.addEventListener('click', e => {
//   driving = true;
//   channel.push('start_pointing', {})
// })

const cardContainer = document.querySelector('.card-container')
channel.on('new_card', state => {
  const template =
    '<div class="card text-left">' +
    '  <div class="card-header">' +
    '    <h2>' + state.card.title + '</h2>' +
    '  </div>' +
    '  <div class="card-body">' +
    '    <p class="card-text">' + state.card.description + '</p>' +
    '    <div class="form-group text-left points-container">' +
    '      <div class="form-row align-items-center">' +
    '        <div class="col-2">' +
    '          <label for="story-points">Story Points</label>' +
    '          <select class="form-control story-points" id="story-points">' +
    '            <option>1</option>' +
    '            <option>2</option>' +
    '            <option>3</option>' +
    '            <option>5</option>' +
    '          </select>' +
    '        </div>' +
    '      </div>' +
    '      <a href="#" class="btn btn-primary calculate-points">Vote!</a>' +
    '    </div>' +
    '  </div>' +
    '</div>'

  renderTemplate(cardContainer, template)

  document
    .querySelector('.calculate-points')
    .addEventListener('click', event => {
      const storyPoints = document.querySelector('.story-points')
      channel.push('user_estimated', { points: storyPoints.value })
    })
})

const renderVotingResults = function(template) {
  const pointContainer = document.querySelector('.points-container')
  renderTemplate(pointContainer, template)

  document
    .querySelector('.next-card')
    .addEventListener('click', e => {
      channel.push('finalized_points', { points: e.target.value })
    })
}

channel.on('winner', state => {
  const template =
    '<p>' + state.points + ' Points </p>' +
    '<button ' + (driving ? '' : 'disabled=true') + ' class="btn btn-primary next-card" value=' + state.points + '>Next Card</a>'

  renderVotingResults(template)
})

channel.on('tie', state => {
  const template =
    '<p class="card-text"> TIE! </p>' +
    '<button ' + (driving ? '' : 'disabled=true') + ' class="btn btn-primary next-card" value=' + state.points[0] + '>Pick ' + state.points[0] + ' </a>' +
    '<button ' + (driving ? '' : 'disabled=true') + ' class="btn btn-primary next-card" value=' + state.points[1] + '>Pick ' + state.points[1] + ' </a>'

  renderVotingResults(template)
})

export default socket
