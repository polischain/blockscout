function getTokenIconUrl (chainID, addressHash) {
  return `https://raw.githubusercontent.com/hadeswap/assets/master/blockchains/olympus/assets/${addressHash}/logo.png`
}

function appendTokenIcon ($tokenIconContainer, chainID, addressHash, foreignChainID, foreignAddressHash, displayTokenIcons, size) {
  const iconSize = size || 20
  var tokenIconURL = null
  if (foreignChainID) {
    tokenIconURL = getTokenIconUrl(foreignChainID.toString(), foreignAddressHash)
  } else if (chainID) {
    tokenIconURL = getTokenIconUrl(chainID.toString(), addressHash)
  }
  if (displayTokenIcons) {
    checkLink(tokenIconURL)
      .then(checkTokenIconLink => {
        if (checkTokenIconLink) {
          if ($tokenIconContainer) {
            var img = new Image(iconSize, iconSize)
            img.src = tokenIconURL
            $tokenIconContainer.append(img)
          }
        }
      })
  }
}

async function checkLink (url) {
  if (url) {
    try {
      const res = await fetch(url)
      return res.ok
    } catch (_error) {
      return false
    }
  } else {
    return false
  }
}

export { appendTokenIcon, checkLink, getTokenIconUrl }
