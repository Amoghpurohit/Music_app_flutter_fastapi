import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/progress_loader.dart';
import 'package:client/features/auth/view/pages/sign_up.dart';
import 'package:client/features/auth/view/widgets/auth_gradient.button.dart';
import 'package:client/core/widgets/custom_form_field_text.dart';
import 'package:client/features/auth/viewModel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginStateWatch = ref.watch(
        authViewModelProvider.select((value) => value?.isLoading == true));

    ref.listen(
      authViewModelProvider,
      (prev, next) {
        next?.when(
          data: (data) {
            Navigator.pushAndRemoveUntil(             //to remove all the previous screens from the stack
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (prev)=>false,
            );
            //Navigate to homepage
          },
          error: (error, stacktrace) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: loginStateWatch
          ? const Center(
              child: ProgressLoader(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign In!',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      text: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFormField(
                      text: 'Password',
                      controller: _passwordController,
                      isObscured: true,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    AuthGradientButton(
                      text: 'Login',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .loginUser(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                        } else {
                          showSnackBar(context, 'missing fields');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: Theme.of(context).textTheme.titleMedium,
                          children: const [
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(
                                color: Pallete.gradient2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
