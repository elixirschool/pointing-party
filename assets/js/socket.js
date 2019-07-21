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
    users.appendChild(user)
  })
})

channel.join()
  .receive('ok', resp => { console.log('Joined successfully', resp) })
  .receive('error', resp => { console.log('Unable to join', resp) })

export default socket
