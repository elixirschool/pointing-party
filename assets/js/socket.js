import {Socket, Presence} from 'phoenix'

const socket = new Socket('/socket', {params: {username: window.pointingParty.username}})
socket.connect()

const channel = socket.channel('room:lobby', {})
const presence = new Presence(channel)

presence.onSync(() => {
  const users = document.querySelector('.users')
  users.innerHTML = ''

  presence.list((id, _) => {
    const user = document.createElement('li')
    user.setAttribute('class', id)
    user.appendChild(document.createTextNode(id))

    const estimate = document.createElement('span')
    estimate.setAttribute('class', 'user-estimate')
    user.appendChild(estimate)

    users.appendChild(user)
  })
})

if (window.pointingParty.username) {
  channel.join ()
    .receive('ok', resp => { console.log('Joined successfully', resp) })
    .receive('error', resp => { console.log('Unable to join', resp) })
}

const calculateButton = document.querySelector('.calculate-points')
calculateButton.addEventListener('click', event => {
  const storyPoints = document.querySelector('.story-points')
  channel.push('user_estimated', { points: storyPoints.value })
})


channel.on("user_estimated", ({ points, userId }) => {
  const user = document.querySelector(`.${userId} .user-estimate`)
  user.innerHTML = points
})

export default socket
