import {Socket, Presence} from 'phoenix'

const socket = new Socket('/socket', {params: {username: window.pointingParty.username}})
socket.connect()

const channel = socket.channel('room:lobby', {})
const presence = new Presence(channel)

presence.onSync(() => {
  const usersElem = document.querySelector('.users')
  updateUsers(usersElem, presence)
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

const updateUsers = (usersElem, presence) => {
  usersElem.innerHTML = ''
  presence.list(updateUser(usersElem))
}

const updateUser = usersElem => (userId, _) => {
  const userElem = document.createElement('li')
  userElem.setAttribute('class', userId)
  userElem.appendChild(document.createTextNode(userId))

  const estimateElem = document.createElement('span')
  estimateElem.setAttribute('class', 'user-estimate')
  userElem.appendChild(estimateElem)

  usersElem.appendChild(userElem)
}

export default socket
