#!/usr/bin/gawk -f 

BEGIN {
  pdutype = 0;
}

function process_h225_pdu(title,        type, tunneling)
{
  while (getline > 0) {
    if ($0 ~ /^  }/) 
      break;
    else if ($1 ~ /h323_message_body/) {
      type = $3;
    } else if ($1 ~ /h245Tunneling/)
      tunneling = $3;
  }
  printf ("%s H225: %s, tunnel = %s\n", title, type, tunneling)
}

function process_h245_pdu(title,          type)
{
  getline;
  type = $2;
  while (getline > 0) {
    if ($0 ~ /^  }/) 
      break;
  }
  printf("%s H245: %s\n", title, type);
}

/H225[\t ]*Received PDU/ {
  process_h225_pdu("RX")
  next;
}

/H225[\t ]*Sending PDU/ {
  process_h225_pdu("TX")
  next;
}

/H245[\t ]*Received PDU/ {
  process_h245_pdu("RX")
  next;
}

/H245[\t ]*Sending PDU/ {
  process_h245_pdu("TX")
  next;
}
