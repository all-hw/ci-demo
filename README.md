# Access All-Hardware service in your CI workflow

CI/CD techniques are coming to the embedded world and recently [All-Hardware](https://all-hw.com) service enabled a remote access to the [AlifSemiconductor Ensemble DevKit-E7](https://www.alifsemi.com) development board. Waiting for your feedback to add support for the rest boards.

This demo is intended to show how to speed-up the process of the embedded firmware development by automation of the app testing on the cloud hardware.

Here we'll run simple echo application on the latest Cortex-M55 AI enabled [AlifSemiconductor](https://www.alifsemi.com) Ensemble DevKit-E7 development board using GitHub Actions and by using REST requests wrapped with shell scripts.

[Ensemble Family](https://www.alifsemi.com/wp-content/uploads/2021/10/ALIF-digital-brochure_Final-6.pdf) devices are a scalable and compatible continuum of highly integrated embedded processors. Designed for power efficiency and long battery life, these devices deliver high computation and ML/AI capability, high-speed connectivity including Ethernet and SDIO, multi-layered security, computer vision, and rich graphical user interfaces.

Individual device selections in the family scale up starting from single-core MCUs, to dual-core MCUs, advancing to triple-core and quad-core fusion processors to match specific applications. Across all devices is a common fabric of features and technology making it easy to re-use software and hardware over varied projects.

### Note

The API key used for this demo is _ba1e491b-331b-4e35-b799-f714b8505843_ which might be disabled. If it stopped to work please visit the [board's page](https://all-hw.com) for the new key.

For this moment the demo is using precompiled examples. To get the source code of the examples please contact [AlifSemiconductor](https://www.alifsemi.com).
Once the source code will be available for the public the demo will be updated with detailed instruction of getting the code and building the project.

### Quick look at the demo content

Clone the demo project from GitHub:

```bash
git clone --recursive https://github.com/all-hw/ci-demo.git
cd ci-demo
```

The DEMO project contains:
- UART echo example application
- TFLite microspeech example application
- scripts to upload firmware binary to the All-Hardware service
- GitHub CI workflow configuration

Ok, great! Let's flash our simple applications to the cloud hardware.

#### HelloWorld

Run following command to upload the Hello World example to the All-Hardware Alif remote board:

```bash
INPUT_API_KEY=ba1e491b-331b-4e35-b799-f714b8505843 INPUT_BINARY=bin/HelloW.axf INPUT_FILE=test_data/uart_input.txt ./scripts/allhw_upload.sh
```

Here is the expected output:
```bash
Executing bin/HelloW.axf on https://cloud.all-hw.com/ci with timeout 10s
Waiting for result... e6185fd8-eb53-473b-b6ef-7e8d3a160111
Result code: 156
UART output: =================VVVVVVVVVVVVV=================================

-- Remote service test application - echo test --
test1...
test2...
test3...
Hello World!!!

Execution timeout detected...

==============================^^^^^^^^^^^^^=================================
```

#### Microspeech

Run following command to upload the Microspeech example to the All-Hardware Alif remote board:

```bash
INPUT_API_KEY=ba1e491b-331b-4e35-b799-f714b8505843 INPUT_BINARY=bin/microspeech.axf INPUT_FILE=test_data/empty.txt ./scripts/allhw_upload.sh
```

Here is the expected output:
```bash
Executing bin/microspeech.axf on https://cloud.all-hw.com/ci with timeout 10s
Waiting for result... 8a668658-a764-4a15-b71f-afb6c8bdaece
Result code: 156
UART output: =================VVVVVVVVVVVVV=================================
UART is enabled.
Heard silence (153) @400ms
Heard yes (158) @1200ms
Heard unknown (141) @5100ms
Heard no (141) @6100ms
..... more lines here ......

==============================^^^^^^^^^^^^^=================================
```

## Demo sources and Toolchain setup

For this moment the demo is using precompiled examples. To get the source code of the examples please contact [AlifSemiconductor](https://www.alifsemi.com).
Once the source code will be available for the public the demo will be updated with detailed instruction of getting the code and building the project.

For building this demo you can use [Arm Virtual Hardware](https://aws.amazon.com/marketplace/pp/prodview-urbpq7yo5va7g) AWS image. Please set it up using provided instructions.

### Microspeech

Microspeech source code available on the [Alif's GitHub page](https://github.com/arashed-alif/VHT-TFLmicrospeech). You can get the source code using following commands:

```bash
git clone https://github.com/arashed-alif/VHT-TFLmicrospeech
cd VHT-TFLmicrospeech
git checkout Platform_Alif_Ensemble
```
Follow the instructions [here](https://github.com/arashed-alif/VHT-TFLmicrospeech/tree/Platform_Alif_Ensemble/Platform_Alif_Ensemble) to build the example.


## GitHub CI integration

With GitHub Actions you can easily build your CI workflow and [All-Hardware](https://all-hw.com) service will let you to do it for your embeded development process!

Open [demo GitHub page](https://github.com/all-hw/ci-demo) and fork the repository:

<img src=docs/fork.png>

Now you have a fork of the CI demo repository on your account on GitHub. Lets try out the CI workflow:

<img src=docs/start_workflow.png>

Congratulations! Your project was successfully built and run on the latest [AlifSemiconductor](https://www.alifsemi.com) Ensemble DevKit-E7 development board!

<img src=docs/workflow_passed.png>

Now let's take a quick look at the workflow configuration file:

```yaml
name: ALL-HW ALIF CI

on:
  # Manually triggered workflow
  workflow_dispatch:
    inputs:
      # parameters description
      binary:
        description: 'Binary for the task'
        default: 'bin/HelloW.axf'
        required: true
      file:
        description: 'Input data for the task'
        default: 'test_data/uart_input.txt'
        required: true
      api_key:
        description: 'API key for the all-hw.com service'
        default: 'ba1e491b-331b-4e35-b799-f714b8505843'
        required: true
      timeout:
        description: 'Firmware task timeout'
        default: '10'
        required: true

jobs:
  build_and_run:
    runs-on: ubuntu-20.04
    steps:
    # checking out our repository
    - name: Check out repository
      uses: actions/checkout@v2
      with:
        submodules: recursive

    # using the parameters provided above we call
    # All-Hardware GitHub actions
    # to upload your firmware to the cloud hardware
    - name: Run firmware upload to All-Hardware
      id: task
      uses: all-hw/uart-task@main
      with:
        binary: ./${{ github.event.inputs.binary }}
        uart-in: ./${{ github.event.inputs.file }}
        api-key: ${{ github.event.inputs.api_key }}
        timeout: ${{ github.event.inputs.timeout }}
      timeout-minutes: 1

    - name: Getting the Status
      run: echo "${{ steps.task.outputs.status }}"

    - name: Getting the UART output
      run: echo "${{ steps.task.outputs.uart-out }}"

    - name: Getting the execution result code
      run: echo "${{ steps.task.outputs.result-code }}"
```

Firmware upload done by [All-Hardware GitHub Actions](https://github.com/all-hw/uart-task) and you can easily integrate it into your own CI workflow.
