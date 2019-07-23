import { Socket, Presence } from 'phoenix'
import updateUsers  from './users'

const socket = new Socket('/socket', {params: {username: window.pointingParty.username}})
socket.connect()

const channel = socket.channel('room:lobby', {})
const presence = new Presence(channel)

presence.onSync(() => updateUsers(presence))

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

export default socket
