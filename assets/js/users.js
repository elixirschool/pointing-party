import {every} from 'lodash'

const updateUsers = presence => {
  const usersElem = document.querySelector('.users')
  usersElem.innerHTML = ''
  const users = presence.list(listBy)
  users.forEach(addUser(usersElem))

  if (allHaveEstimated(users)) {
    users.forEach(showPoints(usersElem))
  }
}

const listBy = (username, metas) => {
  return {userId: username, points: metas.points}
}

// const listBy = (userId,  , ..._rest]}) => ({ userId, points })

const showPoints = usersElem => ({userId, points}) => {
  const userElem = document.querySelector(`.${userId}.user-estimate`)
  userElem.innerHTML = points
}

const addUser = usersElem => ({userId, points}) => {
  const userElem = document.createElement('dt')
  userElem.appendChild(document.createTextNode(userId))
  userElem.setAttribute('class', 'col-8')

  const estimateElem = document.createElement('dd')
  estimateElem.setAttribute('class', `${userId} user-estimate col-4`)

  usersElem.appendChild(userElem)
  usersElem.appendChild(estimateElem)
}

const allHaveEstimated = users => {
  const pointsCollection = users.map(({points}) => points)

  return every(pointsCollection)
}

export default updateUsers
