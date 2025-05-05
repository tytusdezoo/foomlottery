// calculate mask 
function getMask(amount) {
  const betPower1 = 10n;
  const betPower2 = 16n;

  let mask = 0n;
  for(let i = 0n; i <= betPower2; i++) {
    if(amount < (2n + 2n**i)) throw new Error("Invalid bet amount");
    if(amount == (2n + 2n**i)){ 
      if(i<=betPower1){
        mask=(2n**(betPower1+betPower2+1n)-1n)<<i;
      }
      else{
        mask=((2n**betPower2-1n)<<(i+betPower1))|(2n**betPower1-1n);
      }
      mask=mask&(2n**(betPower1+betPower2+1n)-1n);
      break;
    }
  }
  if (mask ==0n ) throw new Error("Invalid bet amount");
  return mask;
}

module.exports = {
  getMask,
};
