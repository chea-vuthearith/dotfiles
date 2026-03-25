{...}: {
  # fake ps4 controller
  services.udev.extraRules = ''
    ATTRS{idVendor}=="2563", ATTRS{idProduct}=="0526", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_PS4}="1"
  '';
}
