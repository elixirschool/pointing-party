import {every} from 'lodash'

const usersElem = document.querySelector('.users')

const updateUsers = presence => {
  usersElem.innerHTML = ''

  // let users = list presences with the help of a listBy function
  users.forEach(addUser)

  // implement a feature that
  // 1. checks if all fo the users in the present list have voted, i.e. have points values that are not null
  // 2. displays the user's vote next to their name if so
}

const listBy = (username, {metas: [{points}, ..._rest]}) => {
  // build out the listBy function so that it returns a list of users
  // where each user looks like this:
  // {username: username, points: points}
}

const showPoints = ({userId, points}) => {
  const userElem = document.querySelector(`.${userId}.user-estimate`)
  userElem.innerHTML = points
}

const addUser = user => {
  const userElem = document.createElement('dt')
  userElem.appendChild(document.createTextNode(user.username))
  userElem.setAttribute('class', 'col-8')

  const estimateElem = document.createElement('dd')
  estimateElem.setAttribute('class', `${user.username} user-estimate col-4`)

  usersElem.appendChild(userElem)
  usersElem.appendChild(estimateElem)
}

export default updateUsers
