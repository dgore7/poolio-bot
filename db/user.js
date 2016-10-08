const mongooose = require('mongoose');

const userSchema = {
  userName: String,
  address: String
}

mongoose.model('User', userSchema);
